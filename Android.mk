LOCAL_PATH := $(call my-dir)

ifneq ($(filter qc750,$(TARGET_DEVICE)),)
include $(call all-makefiles-under,$(LOCAL_PATH))
endif
