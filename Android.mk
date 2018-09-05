LOCAL_PATH := $(call my-dir)

ifneq ($(filter a2109,$(TARGET_DEVICE)),)
include $(call all-makefiles-under,$(LOCAL_PATH))
endif
