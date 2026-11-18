#!/usr/bin/env bash

chosen=$(printf "Reload-Configs\0icon\x1fview-refresh\n" | rofi -dmenu -i -p "Quick Commands" -show-icons)

case "$chosen" in 
    *Reload-Configs*)
        tmux source-files ~/.config/tmux/tmux.conf
        quickshell ipc call shell reloadConfig
        dunstctl reload
        ;;
esac
