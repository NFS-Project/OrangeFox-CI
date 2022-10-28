#!/bin/bash

# Default Branch for Orangefox
FOX_BRANCH="fox_12.1"
ARGS_EXTRA=""
ORANGEFOX_MAINTAINER_NAME="NFS-project"

# Device Tree
DT_LINK="https://github.com/NFS-Project/ofx_device_xiaomi_rosy"
DT_BRANCH="fox_12.1"

DEVICE="rosy"
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
EXTRA_CMD2="git clone --depth=1 https://github.com/TeamWin/android_device_xiaomi_mithorium-common -b android-12.1 device/xiaomi/mithorium-common"
EXTRA_CMD3=""
EXTRA_CMD4=""
EXTRA_CMD5=""

# Magisk
## Use the Latest Release of Magisk for the OrangeFox addon
OF_USE_LATEST_MAGISK=true

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




# Don't change this line
#===========================================
DISTRO=$(source /etc/os-release && echo "${PRETTY_NAME}")

TERM=xterm
red=$(tput setaf 1)             #  red
grn=$(tput setaf 2)             #  green
blu=$(tput setaf 4)             #  blue
cya=$(tput setaf 6)             #  cyan
txtrst=$(tput sgr0)             #  Reset

timeStart() {
    DATELOG=$(date "+%H%M-%d%m%Y")
    BUILD_START=$(date +"%s")
    DATE=$(date)
}

timeEnd() {
	BUILD_END=$(date +"%s")
	DIFF=$(($BUILD_END - $BUILD_START))
}

telegram_curl() {
    local ACTION=${1}
    shift
    local HTTP_REQUEST=${1}
    shift
    if [[ "${HTTP_REQUEST}" != "POST_FILE" ]]; then
        curl -s -X "${HTTP_REQUEST}" "https://api.telegram.org/bot$TG_TOKEN/$ACTION" "$@" | jq .
    else
        curl -s "https://api.telegram.org/bot$TG_TOKEN/$ACTION" "$@" | jq .
    fi
}

telegram_main() {
    local ACTION=${1}
    local HTTP_REQUEST=${2}
    local CURL_ARGUMENTS=()
    while [[ "${#}" -gt 0 ]]; do
        case "${1}" in
            --animation | --audio | --document | --photo | --video )
                local CURL_ARGUMENTS+=(-F $(echo "${1}" | sed 's/--//')=@"${2}")
                shift
                ;;
            --* )
                if [[ "$HTTP_REQUEST" != "POST_FILE" ]]; then
                    local CURL_ARGUMENTS+=(-d $(echo "${1}" | sed 's/--//')="${2}")
                else
                    local CURL_ARGUMENTS+=(-F $(echo "${1}" | sed 's/--//')="${2}")
                fi
                shift
                ;;
        esac
        shift
    done
    telegram_curl "${ACTION}" "${HTTP_REQUEST}" "${CURL_ARGUMENTS[@]}"
}

telegram_curl_get() {
    local ACTION=${1}
    shift
    telegram_main "${ACTION}" GET "$@"
}

telegram_curl_post() {
    local ACTION=${1}
    shift
    telegram_main "${ACTION}" POST "$@"
}

telegram_curl_post_file() {
    local ACTION=${1}
    shift
    telegram_main "${ACTION}" POST_FILE "$@"
}

tg_send_message() {
    telegram_main sendMessage POST "$@"
}

tg_edit_message_text() {
    telegram_main editMessageText POST "$@"
}

tg_send_document() {
    telegram_main sendDocument POST_FILE "$@"
}

progress() {
    echo "BOTLOG: Build tracker process is running..."
    sleep 5;

    while [ 1 ]; do
        if [[ ${retVal} -ne 0 ]]; then
            exit ${retVal}
        fi

        # Get latest percentage
        PERCENTAGE=$(cat $BUILDLOG | tail -n 1 | awk '{ print $2 }')
        NUMBER=$(echo ${PERCENTAGE} | sed 's/[^0-9]*//g')

        # Report percentage to the $TG_CHAT_ID
        if [[ "${NUMBER}" != "" ]]; then
            if [[ "${NUMBER}" -le  "99" ]]; then
                if [[ "${NUMBER}" != "${NUMBER_OLD}" ]] && [[ "$NUMBER" != "" ]] && ! cat $BUILDLOG | tail  -n 1 | grep "glob" > /dev/null && ! cat $BUILDLOG | tail  -n 1 | grep "including" > /dev/null && ! cat $BUILDLOG | tail  -n 1 | grep "soong" > /dev/null && ! cat $BUILDLOG | tail  -n 1 | grep "finishing" > /dev/null; then
                echo -e "BOTLOG: Percentage changed to ${NUMBER}%"
                    build_message "🛠️ Building... ${NUMBER}%" > /dev/null
                fi
            NUMBER_OLD=${NUMBER}
            fi
            if [[ "$NUMBER" -eq "99" ]] && [[ "$NUMBER" != "" ]] && ! cat $BUILDLOG | tail  -n 1 | grep "glob" > /dev/null && ! cat $BUILDLOG | tail  -n 1 | grep "including" > /dev/null && ! cat $BUILDLOG | tail  -n 1 | grep "soong" > /dev/null && ! cat $BUILDLOG | tail -n 1 | grep "finishing" > /dev/null; then
                echo "BOTLOG: Build tracker process ended"
                break
            fi
        fi

        sleep 5
    done
    return 0
}

build_message() {
	if [ "$CI_MESSAGE_ID" = "" ]; then
CI_MESSAGE_ID=$(tg_send_message --chat_id "$TG_CHAT_ID" --text "<b>=== Starting Build OrangeFox ===</b>
<b>Branch:</b> <code>${FOX_BRANCH}</code>
<b>Device:</b> <code>${DEVICE}</code>
<b>Type:</b> <code>${BUILDTYPE}</code>
<b>Job:</b> <code>$(nproc --all) Paralel processing</code>
<b>Running on:</b> <code>$DISTRO</code>
<b>Started at</b> <code>$DATE</code>

<b>Status:</b> <code>${1}</code>" --parse_mode "html" | jq .result.message_id)
	else
tg_edit_message_text --chat_id "$TG_CHAT_ID" --message_id "$CI_MESSAGE_ID" --text "<b>=== Starting Build OrangeFox ===</b>
<b>Branch:</b> <code>${FOX_BRANCH}</code>
<b>Device:</b> <code>${DEVICE}</code>
<b>Type:</b> <code>${BUILDTYPE}</code>
<b>Job:</b> <code>$(nproc --all) Paralel processing</code>
<b>Running on:</b> <code>$DISTRO</code>
<b>Started at</b> <code>$DATE</code>

<b>Status:</b> <code>${1}</code>" --parse_mode "html"
	fi
}

statusBuild() {
    if [[ $retVal -eq 8 ]]; then
        build_message "Build Aborted 😡 with Code Exit ${retVal}.

Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
        tg_send_message --chat_id "$TG_CHAT_ID_SECOND" --text "Build Aborted 💔 with Code Exit ${retVal}.
Sudah kubilang yang teliti 😡"
        echo "Build Aborted"
        tg_send_document --chat_id "$TG_CHAT_ID" --document "$BUILDLOG" --reply_to_message_id "$CI_MESSAGE_ID"
        LOGTRIM="$CDIR/out/log_trimmed.log"
        sed -n '/FAILED:/,//p' $BUILDLOG &> $LOGTRIM
        tg_send_document --chat_id "$TG_CHAT_ID" --document "$LOGTRIM" --reply_to_message_id "$CI_MESSAGE_ID"
        exit $retVal
    fi
    if [[ $retVal -eq 141 ]]; then
        build_message "Build Aborted 👎 with Code Exit ${retVal}, See log.

Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
        tg_send_message --chat_id "$TG_CHAT_ID_SECOND" --text "Build Aborted 💔 with Code Exit ${retVal}."
        echo "Build Aborted"
        tg_send_document --chat_id "$TG_CHAT_ID" --document "$BUILDLOG" --reply_to_message_id "$CI_MESSAGE_ID"
        LOGTRIM="$CDIR/out/log_trimmed.log"
        sed -n '/FAILED:/,//p' $BUILDLOG &> $LOGTRIM
        tg_send_document --chat_id "$TG_CHAT_ID" --document "$LOGTRIM" --reply_to_message_id "$CI_MESSAGE_ID"
        exit $retVal
    fi
    if [[ $retVal -ne 0 ]]; then
        build_message "Build Error 💔 with Code Exit ${retVal}, See log.

Total time elapsed: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
        tg_send_message --chat_id "$TG_CHAT_ID_SECOND" --text "Build Error 💔 with Code Exit ${retVal}."
        echo "Build Error"
        tg_send_document --chat_id "$TG_CHAT_ID" --document "$BUILDLOG" --reply_to_message_id "$CI_MESSAGE_ID"
        LOGTRIM="$CDIR/out/log_trimmed.log"
        sed -n '/FAILED:/,//p' $BUILDLOG &> $LOGTRIM
        tg_send_document --chat_id "$TG_CHAT_ID" --document "$LOGTRIM" --reply_to_message_id "$CI_MESSAGE_ID"
        exit $retVal
    fi
    build_message "Build success ❤️"
    tg_send_message --chat_id "$TG_CHAT_ID" --text "Build Success ❤️
Congratsss I'm Happy for you :v"
}
