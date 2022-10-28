#!/bin/bash

# Source Configs
source $CONFIG

msg() {
    echo -e "\e[1;32m$*\e[0m"
}

# Telegram
tg_check=$(grep 'TG' $CONFIG | wc -l)
if [[ $tg_check -gt 0 ]]; then
    echo "ERROR - Anda Tidak Dapat Menyetel *TG* Vars di $CONFIG"
    exit 1
fi

# Do not allow curl
curl_check=$(grep 'curl ' $CONFIG | wc -l)
if [[ $curl_check -gt 0 ]]; then
    echo -e "Tolong jangan gunakan \'curl\' di $CONFIG".
    exit 1
fi

if [[ "$DEVICE" == "" ]]; then
    echo "Environment untuk 'DEVICE' kosong, silakan atur dengan mengedit $CONFIG"
    exit 1
elif [[ "$ORANGEFOX_MAINTAINER_NAME" == "" ]]; then
    echo "Environment untuk 'ROM_NAME' kosong, silakan atur dengan mengedit $CONFIG"
    exit 1
elif [[ "$FOX_BRANCH" == "" ]]; then
    echo "Environment untuk 'BRANCH_MANIFEST' kosong, silakan atur dengan mengedit $CONFIG"
    exit 1
elif [[ "$DT_LINK" == "" ]]; then
    echo "Environment untuk 'TG_TOKEN' kosong, silakan atur dengan mengedit $CONFIG"
    exit 1
elif [[ "$DT_BRANCH" == "" ]]; then
    echo "Environment untuk 'CHAT_ID' kosong, silakan atur dengan mengedit $CONFIG"
    exit 1
elif [[ "$TARGET" == "" ]]; then
    echo "Environment untuk 'G_H_TOKEN' kosong, silakan atur dengan mengedit $CONFIG"
    exit 1
elif [[ "$OUTPUT" == "" ]]; then
    echo "Environment untuk 'BUILDTYPE' kosong, silakan atur dengan mengedit $CONFIG"
    exit 1
else
    echo "Semua akan baik baik saja hehe!"
fi

msg Passed
