#!/bin/bash

# Source Vars
source $CONFIG

# Change to the Source Directory
cd $SYNC_PATH

# Change to the Output Directory
cd out/target/product/${DEVICE}

DATE_L=$(date +%d\ %B\ %Y)
DATE_S=$(date +"%T")

# Color
ORANGE='\033[0;33m'

# Set FILENAME var
FILENAME=$(echo $OUTPUT)

# A Function to Send Posts to Telegram
telegram_message() {
	curl -v "https://api.telegram.org/bot""$TG_TOKEN""/sendPhoto?chat_id=""$TG_CHAT_ID""$ARGS_EXTRA" -H 'Content-Type: multipart/form-data' \
	--form photo="$END_BUILD_LOGO" \
	-F "parse_mode=html" \
	-F caption="$1"
}

# Display a message
echo "============================"
echo "Uploading the Build..."
echo "============================"

# Upload to oshi.at
if [ -z "$TIMEOUT" ];then
    TIMEOUT=20160
fi

# Upload to WeTransfer
# NOTE: the current Docker Image, "registry.gitlab.com/sushrut1101/docker:latest", includes the 'transfer' binary by Default
transfer wet $FILENAME > link.txt || { echo "ERROR: Failed to Upload the Build!" && exit 1; }

# Mirror to oshi.at
curl -T $FILENAME https://oshi.at/${FILENAME}/${TIMEOUT} > mirror.txt || { echo "WARNING: Failed to Mirror the Build!"; }

DL_LINK=$(cat link.txt | grep Download | cut -d\  -f3)
MIRROR_LINK=$(cat mirror.txt | grep Download | cut -d\  -f1)

# Send the Message on Telegram
echo -e \
"
<b>🦊 OrangeFox Recovery CI</b>
==========================
<b>✅ Build Completed Successfully</b>

<b>📱 Device :</b> "${DEVICE}"
<b>🖥 Branch Build :</b> "${FOX_BRANCH}"
<b>📂 Size :</b> "$(ls -lh $FILENAME | cut -d ' ' -f5)"
<b>⏰ Timer Build :</b> "$(grep "#### build completed successfully" $SYNC_PATH/build.log -m 1 | cut -d '(' -f 2)"
<b>📥 WeTransfer :</b> <a href=\"${SHORT_URL}${DL_LINK}\">Download</a>
<b>📥 oshi.at :</b> <a href=\"${SHORT_URL}${MIRROR_LINK}\">Download</a>
<b>📅 Date :</b> "$(date +%d\ %B\ %Y)"
<b>🕔 Time :</b> "$(date +"%T")"

<b>📕 MD5 :-</b> <code>"$(md5sum $FILENAME | cut -d' ' -f1)"</code>
<b>📘 SHA1 :-</b> <code>"$(sha1sum $FILENAME | cut -d' ' -f1)"</code>
==========================
" > tg.html

TG_TEXT=$(< tg.html)
telegram_message "$TG_TEXT"

echo " "

# Exit
exit 0
