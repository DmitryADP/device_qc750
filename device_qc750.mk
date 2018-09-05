DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay

# Build characteristics setting
PRODUCT_CHARACTERISTICS := tablet

PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := hdpi

# Dalvik VM config
include frameworks/native/build/tablet-7in-hdpi-1024-dalvik-heap.mk

# we have enough storage space to hold precise GC data
PRODUCT_TAGS += dalvik.gc.type-precise

$(call inherit-product, $(SRC_TARGET_DIR)/product/languages_full.mk)

# Init files
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/fstab.qc750:root/fstab.qc750 \
    $(LOCAL_PATH)/rootdir/init.qc750.rc:root/init.qc750.rc \
    $(LOCAL_PATH)/rootdir/init.qc750_board.usb.rc:root/init.qc750_board.usb.rc \
    $(LOCAL_PATH)/rootdir/ueventd.qc750.rc:root/ueventd.qc750.rc

# Nvidia hardware, vendor blobs
$(call inherit-product, vendor/nvidia/tegra3/nvidia-vendor.mk)
$(call inherit-product-if-exists, vendor/wexler/qc750/device-vendor.mk)
$(call inherit-product, hardware/nvidia/tegra3/tegra3.mk)

# Set default USB interface
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    persist.sys.usb.config=mtp

# Wifi
PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/ti/wifi_cal_conv_mac.sh:system/bin/wifi_cal_conv_mac.sh \
	$(LOCAL_PATH)/ti/convert_mac.sh:system/bin/convert_mac.sh \
	$(LOCAL_PATH)/ti/busybox:system/bin/busybox \
	$(LOCAL_PATH)/ti/hciconfig:system/bin/hciconfig \
	$(LOCAL_PATH)/ti/wifi_address.sh:system/bin/wifi_address.sh \
	$(LOCAL_PATH)/ti/wifi_channel.sh:system/bin/wifi_channel.sh \
	$(LOCAL_PATH)/ti/udp_port_any.sh:system/bin/udp_port_any.sh

PRODUCT_PACKAGES += \
                calibrator \
                TQS_S_2.6.ini \
                iw \
                crda \
                regulatory.bin \
                wpa_supplicant.conf \
                p2p_supplicant.conf \
                hostapd.conf \
                ibss_supplicant.conf \
                dhcpd.conf \
                bdt
                
#Wifi firmwares
PRODUCT_PACKAGES += \
		wl1271-nvs_default.bin \
		wl128x-fw-4-sr.bin \
		wl128x-fw-4-mr.bin \
		wl128x-fw-4-plt.bin

# HALs
PRODUCT_PACKAGES += \
    audio.primary.tegra3 \
    audio.a2dp.default \
    audio.usb.default \
    audio.r_submix.default \
    lights.kai \
    init.tf \
    sensors.qc750 \
    akmd8975_service 

# Camera HAL
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    media.stagefright.legacyencoder=true \
    media.stagefright.less-secure=true

# Filesystem management tools
PRODUCT_PACKAGES += \
    make_ext4fs \
    e2fsck \
    setup_fs

# USB
PRODUCT_PACKAGES += com.android.future.usb.accessory

# GPS
PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/general/auto_hslp_keystore.bks:system/etc/gps/cert/auto_hslp_keystore.bks \
	$(LOCAL_PATH)/general/GPSCConfigFile.cfg:system/etc/gps/config/GPSCConfigFile.cfg \
	$(LOCAL_PATH)/general/GpsConfigFile.txt:system/etc/gps/config/GpsConfigFile.txt \
	$(LOCAL_PATH)/general/inavconfigfile.txt:system/etc/gps/config/inavconfigfile.txt \
	$(LOCAL_PATH)/general/patch-X.0.ce:system/etc/gps/patch/patch-X.0.ce \
	$(LOCAL_PATH)/general/pathconfigfile.txt:system/etc/gps/config/pathconfigfile.txt \
	$(LOCAL_PATH)/general/PeriodicConfFile.cfg:system/etc/gps/config/PeriodicConfFile.cfg \
	$(LOCAL_PATH)/general/SuplConfig.spl:system/etc/gps/config/SuplConfig.spl \
	$(LOCAL_PATH)/general/navd:system/bin/navd \
	$(LOCAL_PATH)/general/gps.kai.so:system/lib/hw/gps.tegra.so

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/gps/gps.xml:system/etc/gps/gps.xml
    
PRODUCT_PACKAGES += \
		libgps \
		libgpsservices \
		libmcphalgps \
		libsuplhelperservicejni \
		libsupllocationprovider
		
# The gps config appropriate for this device
$(call inherit-product, device/common/gps/gps_us_supl.mk)

# qc750 specific config files
# Audio config
# !!!Alsa-lib sources: ftp://ftp.alsa-project.org/pub/lib/
PRODUCT_COPY_FILES += \
	external/alsa-lib/src/conf/alsa.conf:system/usr/share/alsa/alsa.conf \
	external/alsa-lib/src/conf/pcm/dsnoop.conf:system/usr/share/alsa/pcm/dsnoop.conf \
	external/alsa-lib/src/conf/pcm/modem.conf:system/usr/share/alsa/pcm/modem.conf \
	external/alsa-lib/src/conf/pcm/dpl.conf:system/usr/share/alsa/pcm/dpl.conf \
	external/alsa-lib/src/conf/pcm/default.conf:system/usr/share/alsa/pcm/default.conf \
	external/alsa-lib/src/conf/pcm/surround51.conf:system/usr/share/alsa/pcm/surround51.conf \
	external/alsa-lib/src/conf/pcm/surround41.conf:system/usr/share/alsa/pcm/surround41.conf \
	external/alsa-lib/src/conf/pcm/surround50.conf:system/usr/share/alsa/pcm/surround50.conf \
	external/alsa-lib/src/conf/pcm/dmix.conf:system/usr/share/alsa/pcm/dmix.conf \
	external/alsa-lib/src/conf/pcm/center_lfe.conf:system/usr/share/alsa/pcm/center_lfe.conf \
	external/alsa-lib/src/conf/pcm/surround40.conf:system/usr/share/alsa/pcm/surround40.conf \
	external/alsa-lib/src/conf/pcm/side.conf:system/usr/share/alsa/pcm/side.conf \
	external/alsa-lib/src/conf/pcm/iec958.conf:system/usr/share/alsa/pcm/iec958.conf \
	external/alsa-lib/src/conf/pcm/rear.conf:system/usr/share/alsa/pcm/rear.conf \
	external/alsa-lib/src/conf/pcm/surround71.conf:system/usr/share/alsa/pcm/surround71.conf \
	external/alsa-lib/src/conf/pcm/front.conf:system/usr/share/alsa/pcm/front.conf \
	external/alsa-lib/src/conf/cards/aliases.conf:system/usr/share/alsa/cards/aliases.conf \
	device/wexler/qc750/bluetooth/bdaddr:system/etc/bluetooth/bdaddr \
	$(LOCAL_PATH)/audio/asound.conf:system/etc/asound.conf \
	$(LOCAL_PATH)/audio/nvaudio_conf.xml:system/etc/nvaudio_conf.xml \
	$(LOCAL_PATH)/audio/audio_policy.conf:system/etc/audio_policy.conf

# Media
PRODUCT_COPY_FILES += \
    frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:system/etc/media_codecs_google_audio.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_telephony.xml:system/etc/media_codecs_google_telephony.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_video.xml:system/etc/media_codecs_google_video.xml \
    $(LOCAL_PATH)/media/media_profiles.xml:system/etc/media_profiles.xml \
    $(LOCAL_PATH)/media/media_codecs.xml:system/etc/media_codecs.xml

# Touchscreen
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/touchscreen/nt1103-ts.idc:system/usr/idc/nt1103-ts.idc

# Input devices
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/keylayouts/Bluetooth_00_06_66_42.kl:system/usr/keylayout/Bluetooth_00_06_66_42.kl \
    $(LOCAL_PATH)/keylayouts/Vendor_044f_Product_d007.kl:system/usr/keylayout/Vendor_044f_Product_d007.kl \
    $(LOCAL_PATH)/keylayouts/Vendor_046d_Product_c21e.kl:system/usr/keylayout/Vendor_046d_Product_c21e.kl \
    $(LOCAL_PATH)/keylayouts/Vendor_057e_Product_0306.kl:system/usr/keylayout/Vendor_057e_Product_0306.kl \
    $(LOCAL_PATH)/keylayouts/gpio-keys.kl:system/usr/keylayout/gpio-keys.kl \
    $(LOCAL_PATH)/keylayouts/tegra-kbc.kl:system/usr/keylayout/tegra-kbc.kl

# Bluetooth
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/bluetooth/sd8787_uapsta.bin:system/etc/firmware/mrvl/sd8787_uapsta.bin \
    $(LOCAL_PATH)/bluetooth/bt_vendor.conf:system/etc/bluetooth/bt_vendor.conf
    
#BT & FM packages
PRODUCT_PACKAGES += \
		uim-sysfs \
		TIInit_10.6.15.bts \
		fmc_ch8_1283.2.bts \
		fm_rx_ch8_1283.2.bts \
		fm_tx_ch8_1283.2.bts
		
# Add permissions, copied straight from grouper, a long time ago...
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/tablet_core_hardware.xml:system/etc/permissions/tablet_core_hardware.xml \
    frameworks/native/data/etc/android.hardware.camera.xml:system/etc/permissions/android.hardware.camera.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:system/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.camera.autofocus.xml:system/etc/permissions/android.hardware.camera.autofocus.xml \
    frameworks/native/data/etc/android.hardware.ethernet.xml:system/etc/permissions/android.hardware.ethernet.xml \
    frameworks/native/data/etc/android.hardware.location.gps.xml:system/etc/permissions/android.hardware.location.gps.xml \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:system/etc/permissions/android.hardware.sensor.gyroscope.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:system/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:system/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:system/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:system/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:system/etc/permissions/android.hardware.bluetooth_le.xml
    
    #add by vin for usi_3g_module
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/usiuna-ril/usiuna-ril.so:system/lib/usiuna-ril.so \
    $(LOCAL_PATH)/usiuna-ril/ppp/chat:system/bin/chat \
    $(LOCAL_PATH)/usiuna-ril/ppp/call-pppd:system/etc/ppp/call-pppd \
    $(LOCAL_PATH)/usiuna-ril/ppp/ip-down:system/etc/ppp/ip-down \
    $(LOCAL_PATH)/usiuna-ril/ppp/ip-up:system/etc/ppp/ip-up \
    $(LOCAL_PATH)/usiuna-ril/apns-conf_sdk.xml:system/etc/apns-conf.xml
    
    PRODUCT_PACKAGES += \
               rild
