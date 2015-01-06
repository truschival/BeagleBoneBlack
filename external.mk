#Support for binary packages
include $(BR2_EXTERNAL)/pkg-cmake-gen-bin.mk
include $(BR2_EXTERNAL)/pkg-bin-only.mk

#include all External packages
include $(sort $(wildcard $(BR2_EXTERNAL)/package/*/*.mk))
