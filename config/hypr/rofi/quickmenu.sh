#!/usr/bin/env bash

if [[ "${ROFI_RETV:-0}" == 0 ]]; then
    echo -en "\0prompt\x1fQuick Menu\n"
    printf "Reload Configs\0icon\x1fview-refresh\n"
    exit 0
fi

if [[ "$ROFI_RETV" == 1 ]]; then
    input="$1"
elif [[ "$ROFI_RETV" == 2 ]]; then
    input="$ROFI_INPUT"
else
    exit 0
fi


input="${input#"${input%%[![:space:]]*}"}"
input="${input%"${input##*[![:space:]]}"}"
lower="${input,,}"

# Timer:
if [[ "$lower" =~ ^timer[[:space:]]+(([0-9]+h)?([0-9]+m)?([0-9]+s)?)([[:space:]]+(.*))?$ ]]; then
    duration="${BASH_REMATCH[1]}"
    hours="${BASH_REMATCH[2]%h}"
    minutes="${BASH_REMATCH[3]%m}"
    seconds="${BASH_REMATCH[4]%s}"
    message="${BASH_REMATCH[6]%s}"

    hours="${hours:-0}"
    minutes="${minutes:-0}"
    seconds="${seconds:-0}"

    total=$((hours * 3600 + minutes * 60 + seconds))
    message="${message:-Done!}"

    if ((total <= 0)); then
        exit 1
    fi

    if [[ "${message%% *}" == "silent" ]]; then
        notify-send "Timer" "$duration timer started"
        (sleep $total && notify-send "Timer" "${message#* }") >/dev/null 2>&1 </dev/null &
        exit 0
    fi
    
    quickshell ipc call quickmenu startTimer $total "$message"
    exit 0
fi


case "$lower" in 
    "reload configs")
        tmux source-files ~/.config/tmux/tmux.conf
        quickshell ipc call shell reloadConfig
        dunstctl reload
        notify-send "Reloaded" "Configs Reloaded."
        ;;
esac










