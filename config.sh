#!/bin/bash

# Default Branch for Orangefox
FOX_BRANCH="fox_9.0"
ARGS_EXTRA=""
ORANGEFOX_MAINTAINER_NAME="zacky"

# Device Tree
DT_LINK="https://github.com/NFS-Project/ofx_device_xiaomi_whyred"
DT_BRANCH="fox_9.0"

DEVICE="whyred"
OEM="xiaomi"

START_BUILD_LOGO="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ5-mjWtyBm11LHi8qJIIwZ9jEmGQ09HsMUX45lpOi5LNCpvBkoC-Loc6td&s=10"
END_BUILD_LOGO="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRYuKUrNG9XTb4Ts5W4gBV61pfgs0Q2wxHuUv1fzKXMYQXF4g1qIYXQgbg&s=10"

# Build Target
## "recoveryimage" - for A-Only Devices without using Vendor Boot
## "bootimage" - for A/B devices without recovery partition (and without vendor boot)
## "vendorbootimage" - for devices Using vendor boot for the recovery ramdisk (Usually for devices shipped with Android 12 or higher)
TARGET="recoveryimage"

OUTPUT="OrangeFox*.zip"

# Kernel Source
# Uncomment the next line if you want to clone a kernel source.
#KERNEL_SOURCE="https://github.com/NFS-Project/android_kernel_xiaomi_rosy"
#KERNEL_BRANCH="thirteen"

# Extra Command
EXTRA_CMD1="git clone https://github.com/OrangeFoxRecovery/Avatar.git misc"
EXTRA_CMD2="git clone --depth=1 https://github.com/NFS-Project/ofx_device_xiaomi_whyred -b fox_9.0 device/xiaomi/whyred"
EXTRA_CMD3=""
EXTRA_CMD4=""
EXTRA_CMD5=""

# Magisk
## Use the Latest Release of Magisk for the OrangeFox addon
OF_USE_LATEST_MAGISK=true

# Maintainer
OF_MAINTAINER=$ORANGEFOX_MAINTAINER_NAME

# Not Recommended to Change
SYNC_PATH="$WORKDIR/OrangeFox" # Full (absolute) path.
CCACHE_SIZE="50G"
J_VAL=8

if [ ! -z "$PLATFORM" ]; then
    KERNEL_PATH="kernel/$OEM/$PLATFORM"
else
    KERNEL_PATH="kernel/$OEM/$DEVICE"
fi
DT_PATH="device/$OEM/$DEVICE"
