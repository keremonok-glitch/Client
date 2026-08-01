THEOS_DEVICE_IP = 
TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MyPvPClient

MyPvPClient_FILES = src/StorageESP.mm
MyPvPClient_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
