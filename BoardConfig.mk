# Copyright (C) 2010 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# This file sets variables that control the way modules are built
# thorughout the system. It should not be used to conditionally
# disable makefiles (the proper mechanism to control what gets
# included in a build is to use PRODUCT_PACKAGES in a product
# definition file).
#

USE_CAMERA_STUB := false
# TARGET_RECOVERY_UI_LIB := librecovery_ui_qc750
RECOVERY_FSTAB_VERSION := 2

# inherit from the proprietary version
-include vendor/wexler/qc750/BoardConfigVendor.mk

include hardware/nvidia/tegra3/BoardConfigCommon.mk

TARGET_NO_RADIOIMAGE := true

TARGET_USERIMAGES_USE_EXT4 := true
TARGET_BOOTLOADER_BOARD_NAME := qc750

BOARD_KERNEL_CMDLINE := androidboot.selinux=enforcing androidboot.hardware=kai
BOARD_KERNEL_BASE := 0x10000000
BOARD_KERNEL_PAGESIZE := 2048
TARGET_KERNEL_CONFIG := cl2n_defconfig
TARGET_KERNEL_SOURCE := kernel/nvidia/tegra3
KERNEL_TOOLCHAIN := $(ANDROID_BUILD_TOP)/prebuilts/gcc/$(HOST_OS)-x86/arm/arm-eabi-4.8/bin
KERNEL_TOOLCHAIN_PREFIX := arm-eabi-

# System partition might be too small, if so, disable journaling on system.img to save space.
BOARD_SYSTEMIMAGE_JOURNAL_SIZE := 0
BOARD_BOOTIMAGE_PARTITION_SIZE := 8388608
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 8388608
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 681574400
BOARD_CACHEIMAGE_PARTITION_SIZE := 464519168
BOARD_USERDATAIMAGE_PARTITION_SIZE := 6567231488
BOARD_FLASH_BLOCK_SIZE := 4096

# Only pre-optimize the boot image
WITH_DEXPREOPT_BOOT_IMG_ONLY := true

# Configure jemalloc for low-memory
MALLOC_SVELTE := true

# Use clang platform builds
USE_CLANG_PLATFORM_BUILD := true

# Set HAL1 to fix loading the camera, due to old libnvodm_{query,imager}.so
TARGET_HAS_LEGACY_CAMERA_HAL1 := true

BOARD_HAVE_WIFI := true
# Wifi related defines
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
WPA_SUPPLICANT_VERSION      := VER_0_8_X_TI
BOARD_HOSTAPD_DRIVER        := NL80211
BOARD_WLAN_DEVICE           := wl12xx_mac80211
BOARD_SOFTAP_DEVICE         := wl12xx_mac80211
WIFI_DRIVER_MODULE_NAME     := "wl12xx_sdio"
WIFI_FIRMWARE_LOADER        := ""
USES_TI_MAC80211            := true

TARGET_BOOTLOADER_BOARD_NAME := qc750
#TARGET_BOARD_INFO_FILE := device/wexler/qc750/board-info.txt

# assert
TARGET_OTA_ASSERT_DEVICE := kai,qc750

TARGET_NO_BOOTLOADER := true

BOARD_USES_GENERIC_INVENSENSE := false

# Audio Options
USE_NEW_LIBAUDIO := 1
BOARD_USES_GENERIC_AUDIO := false
BOARD_USES_ALSA_AUDIO := true
BOARD_SUPPORT_NVOICE := true

TARGET_NEEDS_PLATFORM_TEXTRELS := true

# GPS
BOARD_HAVE_TI_GPS := false

# Default HDMI mirror mode
# Crop (default) picks closest mode, crops to screen resolution
# Scale picks closest mode, scales to screen resolution (aspect preserved)
# Center picks a mode greater than or equal to the panel size and centers;
#     if no suitable mode is available, reverts to scale
BOARD_HDMI_MIRROR_MODE := Scale

# This should be enabled if you wish to use information from hwcomposer to enable
# or disable DIDIM during run-time.
BOARD_HAS_DIDIM := true

# This should be set to true for boards that support 3DVision.
BOARD_HAS_3DV_SUPPORT := true

# Bluetooth
BOARD_HAVE_BLUETOOTH := true
BOARD_HAVE_BLUETOOTH_TI := true
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/wexler/qc750/bluetooth

# Use Cortex A9 optimizations for A7
USE_ALL_OPTIMIZED_STRING_FUNCS := true

# Turn on Cortex A9 Optimizations for A7
TARGET_EXTRA_CFLAGS += $(call cc-option,-mtune=cortex-a9) $(call cc-option,-mcpu=cortex-a9)

ifneq ($(HAVE_NVIDIA_PROP_SRC),false)
# needed for source compilation of nvidia libraries
-include vendor/nvidia/proprietary_src/build/definitions.mk
-include vendor/nvidia/build/definitions.mk
endif

# Security
BOARD_SEPOLICY_DIRS += \
        device/wexler/qc750/sepolicy

TARGET_RECOVERY_FSTAB = device/wexler/qc750/rootdir/fstab.qc750
