/*
 * Copyright (C) 2012 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#include <fcntl.h>

#include "isl29018.h"
#include "MPLSensor.h"
#include "MPLSensorDefs.h"
#include "MPLSensorSysApi.h"

#include "bma250.h"
#include "dmard06.h"

#define LUX_SYSFS_PATH  "/sys/bus/iio/devices/device0/illuminance0_input"
#define PROX_SYSFS_PATH  "/sys/bus/iio/devices/device0/proximity_raw"

static const struct sensor_t sSensorList[] = {

      DMARD06_DEF(ID_A),
      BMA250_DEF(ID_A),
};

/*****************************************************************************/

static int open_sensors(const struct hw_module_t* module, const char* id,
                        struct hw_device_t** device);


static int initFailed = 0;
static int sensors__get_sensors_list(struct sensors_module_t* module,
                                     struct sensor_t const** list)
{
    if (initFailed) return 0;

    *list = sSensorList;
    return ARRAY_SIZE(sSensorList);
}

static struct hw_module_methods_t sensors_module_methods = {
        open: open_sensors
};

struct sensors_module_t HAL_MODULE_INFO_SYM = {
        common: {
                tag: HARDWARE_MODULE_TAG,
                version_major: 1,
                version_minor: 0,
                id: SENSORS_HARDWARE_MODULE_ID,
                name: "Kai sensors module",
                author: "nvidia",
                methods: &sensors_module_methods,
                dso: NULL,
                reserved: {0}
        },
        get_sensors_list: sensors__get_sensors_list,
};

struct sensors_poll_context_t {
    struct sensors_poll_device_t device; // must be first

        sensors_poll_context_t();
        ~sensors_poll_context_t();
    int activate(int handle, int enabled);
    int setDelay(int handle, int64_t ns);
    int pollEvents(sensors_event_t* data, int count);

private:
    enum {
        light             = 0,
        proximity         = 1,
        mpl               = 2,
        mpl_accel,
        mpl_timer,
        accel,
        numSensorDrivers,       // wake pipe goes here
        mpl_power,              //special handle for MPL pm interaction
        numFds,
    };

    static const size_t wake = numFds - 2;
    static const char WAKE_MESSAGE = 'W';
    struct pollfd mPollFds[numFds];
    int mWritePipeFd;
    SensorBase* mSensors[numSensorDrivers];

    int handleToDriver(int handle) const {
        switch (handle) {
	      case ID_A:
		  return accel;
        }
        return -EINVAL;
    }
};

/*****************************************************************************/

sensors_poll_context_t::sensors_poll_context_t()
{
    FUNC_LOG;

    mSensors[mpl] = NULL;
    mPollFds[mpl].fd = -1;
    mPollFds[mpl].events = 0;
    mPollFds[mpl].revents = 0;

    mSensors[mpl_accel] = NULL;
    mPollFds[mpl_accel].fd = -1;
    mPollFds[mpl_accel].events = 0;
    mPollFds[mpl_accel].revents = 0;

    mSensors[mpl_timer] = NULL;
    mPollFds[mpl_timer].fd = -1;
    mPollFds[mpl_timer].events = 0;
    mPollFds[mpl_timer].revents = 0;

    mSensors[light] = NULL;
    mPollFds[light].fd = -1;
    mPollFds[light].events = 0;
    mPollFds[light].revents = 0;

    mSensors[proximity] = NULL;
    mPollFds[proximity].fd = -1;
    mPollFds[proximity].events = 0;
    mPollFds[proximity].revents = 0;

   SensorBase*  sensor =new Dmard06(ID_A);
    if(sensor->getFd() <0){
	delete sensor;
	sensor =new Bma250(ID_A);
    }
    mSensors[accel] = sensor;
    mPollFds[accel].fd =mSensors[accel]->getFd();
    mPollFds[accel].events = POLLIN;
    mPollFds[accel].revents = 0;

    int wakeFds[2];
    int result = pipe(wakeFds);
    LOGE_IF(result<0, "error creating wake pipe (%s)", strerror(errno));
    fcntl(wakeFds[0], F_SETFL, O_NONBLOCK);
    fcntl(wakeFds[1], F_SETFL, O_NONBLOCK);
    mWritePipeFd = wakeFds[1];

    mPollFds[wake].fd = wakeFds[0];
    mPollFds[wake].events = POLLIN;
    mPollFds[wake].revents = 0;

    //setup MPL pm interaction handle
    mPollFds[mpl_power].fd = -1;
    mPollFds[mpl_power].events = 0;
    mPollFds[mpl_power].revents = 0;


    LOGD("sensors_poll_context_t over");	
}

sensors_poll_context_t::~sensors_poll_context_t()
{
    FUNC_LOG;
    for (int i=0 ; i<numSensorDrivers ; i++) {
	 if(mSensors[i]!=NULL){
        	delete mSensors[i];
	 }
    }
    close(mPollFds[wake].fd);
    close(mWritePipeFd);
}

int sensors_poll_context_t::activate(int handle, int enabled)
{
    FUNC_LOG;
    int index = handleToDriver(handle);
    if (index < 0) return index;
    int err =  mSensors[index]->enable(handle, enabled);
    if (!err) {
        const char wakeMessage(WAKE_MESSAGE);
        int result = write(mWritePipeFd, &wakeMessage, 1);
        LOGE_IF(result<0, "error sending wake message (%s)", strerror(errno));
    }
    return err;
}

int sensors_poll_context_t::setDelay(int handle, int64_t ns)
{
    FUNC_LOG;
    int index = handleToDriver(handle);
    if (index < 0) return index;
    return mSensors[index]->setDelay(handle, ns);
}

int sensors_poll_context_t::pollEvents(sensors_event_t* data, int count)
{
    FUNC_LOG;
    int nbEvents = 0;
    int n = 0;
    int polltime = -1;

    do {
        // see if we have some leftover from the last poll()
        for (int i=0 ; count && i<numSensorDrivers ; i++) {
            SensorBase* const sensor(mSensors[i]);
            if (sensor && ((mPollFds[i].revents & POLLIN) || (sensor->hasPendingEvents()))) {
                int nb = sensor->readEvents(data, count);
                if (nb <= count ) {
                    // no more data for this sensor
                    mPollFds[i].revents = 0;
                }
                count -= nb;
                nbEvents += nb;
                data += nb;
            }
        }

        if (count) {
            // we still have some room, so try to see if we can get
            // some events immediately or just wait if we don't have
            // anything to return
            int i;

            n = poll(mPollFds, numFds, nbEvents ? 0 : polltime);
            if (n<0) {
                LOGE("poll() failed (%s)", strerror(errno));
                return -errno;
            }
            if (mPollFds[wake].revents & POLLIN) {

		  LOGD("wake...event");
				
                char msg;
                int result = read(mPollFds[wake].fd, &msg, 1);
                LOGE_IF(result<0, "error reading from wake pipe (%s)", strerror(errno));
                LOGE_IF(msg != WAKE_MESSAGE, "unknown message on wake queue (0x%02x)", int(msg));
                mPollFds[wake].revents = 0;
            }
            if(mPollFds[mpl_power].revents & POLLIN) {
		  LOGD("mpl_power...event");
                ((MPLSensor*)mSensors[mpl])->handlePowerEvent();
                mPollFds[mpl_power].revents = 0;
            }
        }
        // if we have events and space, go read them
    } while (n && count);

    return nbEvents;
}

/*****************************************************************************/

static int poll__close(struct hw_device_t *dev)
{
    FUNC_LOG;
    sensors_poll_context_t *ctx = (sensors_poll_context_t *)dev;
    if (ctx) {
        delete ctx;
    }
    return 0;
}

static int poll__activate(struct sensors_poll_device_t *dev,
                          int handle, int enabled)
{
    FUNC_LOG;
    sensors_poll_context_t *ctx = (sensors_poll_context_t *)dev;
    return ctx->activate(handle, enabled);
}

static int poll__setDelay(struct sensors_poll_device_t *dev,
                          int handle, int64_t ns)
{
    FUNC_LOG;
    sensors_poll_context_t *ctx = (sensors_poll_context_t *)dev;
    return ctx->setDelay(handle, ns);
}

static int poll__poll(struct sensors_poll_device_t *dev,
                      sensors_event_t* data, int count)
{
    //FUNC_LOG;
    sensors_poll_context_t *ctx = (sensors_poll_context_t *)dev;
    return ctx->pollEvents(data, count);
}

/*****************************************************************************/

/** Open a new instance of a sensor device using name */
static int open_sensors(const struct hw_module_t* module, const char* id,
                        struct hw_device_t** device)
{
    FUNC_LOG;
    int status = -EINVAL;
    sensors_poll_context_t *dev = new sensors_poll_context_t();

    memset(&dev->device, 0, sizeof(sensors_poll_device_t));

    dev->device.common.tag = HARDWARE_DEVICE_TAG;
    dev->device.common.version  = 0;
    dev->device.common.module   = const_cast<hw_module_t*>(module);
    dev->device.common.close    = poll__close;
    dev->device.activate        = poll__activate;
    dev->device.setDelay        = poll__setDelay;
    dev->device.poll            = poll__poll;

    *device = &dev->device.common;
    status = 0;

    return status;
}
