#!/bin/bash

# Source Configs
source $CONFIG

msg() {
    echo -e "\e[1;32m$*\e[0m"
}

if [[ "$DEVICE" == "" ]]; then
    echo "Environment untuk 'DEVICE' kosong, silakan atur dengan mengedit $CONFIG"
    exit 1
elif [[ "$ORANGEFOX_MAINTAINER_NAME" == "" ]]; then
    echo "Environment untuk 'ORANGEFOX_MAINTAINER_NAME' kosong, silakan atur dengan mengedit $CONFIG"
    exit 1
elif [[ "$FOX_BRANCH" == "" ]]; then
    echo "Environment untuk 'FOX_BRANCH' kosong, silakan atur dengan mengedit $CONFIG"
    exit 1
elif [[ "$DT_LINK" == "" ]]; then
    echo "Environment untuk 'DT_LINK' kosong, silakan atur dengan mengedit $CONFIG"
    exit 1
elif [[ "$DT_BRANCH" == "" ]]; then
    echo "Environment untuk 'DT_BRANCH' kosong, silakan atur dengan mengedit $CONFIG"
    exit 1
elif [[ "$TARGET" == "" ]]; then
    echo "Environment untuk 'TARGET' kosong, silakan atur dengan mengedit $CONFIG"
    exit 1
elif [[ "$OUTPUT" == "" ]]; then
    echo "Environment untuk 'OUTPUT' kosong, silakan atur dengan mengedit $CONFIG"
    exit 1
else
    echo "Semua akan baik baik saja hehe!"
fi

msg Passed
