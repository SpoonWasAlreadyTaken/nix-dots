#!/usr/bin/env bash

STATE_FILE="${XDG_RUNTIME_DIR}/dunst-sound-${DUNST_ID}"
[[ -e "$STATE_FILE" ]] && exit 0
touch "$STATE_FILE"

pw-play ~/.config/scripts/sounds/Notification.wav &

