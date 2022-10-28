#!/bin/bash

# Source Configs
source $CONFIG

timeStart

# Change to the Source Directry
cd $SYNC_PATH

# Sync Branch (will be used to fix legacy build system errors)
if [ -z "$SYNC_BRANCH" ]; then
    export SYNC_BRANCH=$(echo ${FOX_BRANCH} | cut -d_ -f2)
fi

# Set-up ccache
if [ -z "$CCACHE_SIZE" ]; then
    ccache -M 10G
else
    ccache -M ${CCACHE_SIZE}
fi

# Empty the VTS Makefile
if [ "$FOX_BRANCH" = "fox_11.0" ]; then
    rm -rf frameworks/base/core/xsd/vts/Android.mk
    touch frameworks/base/core/xsd/vts/Android.mk 2>/dev/null || echo
fi

# Send the Telegram Message
telegram_message
echo " "

# Run the Extra Command
$EXTRA_CMD1
$EXTRA_CMD2
$EXTRA_CMD3
$EXTRA_CMD4
$EXTRA_CMD5

# export some Basic Vars
echo -e ${blu}"CCACHE is enabled for this build"${txtrst}
export ALLOW_MISSING_DEPENDENCIES=true
export FOX_USE_TWRP_RECOVERY_IMAGE_BUILDER=1
export LC_ALL="C"
export PATH="/usr/lib/ccache:$PATH"
export USE_CCACHE=1
export CCACHE_DIR="$WORKDIR/ccache"
export CCACHE_EXEC=$(which ccache)
export CCACHE_COMPRESS=true
which ccache
ccache -z
BUILDLOG="$SYNC_PATH/build.log"

# Default Build Type
if [ -z "$FOX_BUILD_TYPE" ]; then
    export FOX_BUILD_TYPE="Release-$(date +%d\-%B\-%Y)"
fi

# Prepare the Build Environment
build_message "Prepare for build..."
. build/envsetup.sh

# Default Maintainer's Name
[ -z "$OF_MAINTAINER" ] && export OF_MAINTAINER="$ORANGEFOX_MAINTAINER_NAME"

# Set BRANCH_INT variable for future use
BRANCH_INT=$(echo $SYNC_BRANCH | cut -d. -f1)

# Magisk
if [[ $OF_USE_LATEST_MAGISK = "true" || $OF_USE_LATEST_MAGISK = "1" ]]; then
	echo "Using the Latest Release of Magisk..."
	export FOX_USE_SPECIFIC_MAGISK_ZIP=$("ls" ~/Magisk/Magisk*.zip)
fi

# Legacy Build Systems
if [ $BRANCH_INT -le 6 ]; then
    export OF_DISABLE_KEYMASTER2=1 # Disable Keymaster2
    export OF_LEGACY_SHAR512=1 # Fix Compilation on Legacy Build Systems
fi

# lunch the target
if [ "$BRANCH_INT" -ge 11 ]; then
    build_message "lunch twrp_${DEVICE}-eng"
    lunch twrp_${DEVICE}-eng || { echo "ERROR: Failed to lunch the target!" && exit 1; }
else
    build_message "lunch omni_${DEVICE}-eng"
    lunch omni_${DEVICE}-eng || { echo "ERROR: Failed to lunch the target!" && exit 1; }
fi

# Build the Code
mkfifo reading
tee "${BUILDLOG}" < reading &
build_message "Staring bro...🔥"
sleep 2
build_message "🛠️ Building..."
if [ -z "$J_VAL" ]; then
    progress |& mka -j$(nproc --all) $TARGET > reading || { echo "ERROR: Failed to Build OrangeFox!" && exit 1; }
elif [ "$J_VAL"="0" ]; then
    progress |& mka $TARGET > reading || { echo "ERROR: Failed to Build OrangeFox!" && exit 1; }
else
    progress |& mka -j${J_VAL} $TARGET > reading || { echo "ERROR: Failed to Build OrangeFox!" && exit 1; }
fi

retVal=$?
timeEnd
statusBuild

# Exit
exit 0
