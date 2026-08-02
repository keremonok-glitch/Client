TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MyPvPClient

MyPvPClient_FILES = src/StorageESP.mm
MyPvPClient_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore
MyPvPClient_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
