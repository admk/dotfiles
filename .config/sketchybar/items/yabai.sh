#!/bin/bash

yabai=(
    icon=$YABAI_GRID
    icon.y_offset=0
    label.drawing=off
    script="$PLUGIN_DIR/yabai.sh"
    # icon.font="$FONT:Bold:12.0"
)

sketchybar --add event update_yabai_icon
sketchybar --add item yabai left \
    --set yabai "${yabai[@]}" \
    --subscribe yabai space_change \
    mouse.scrolled.global \
    mouse.clicked \
    front_app_switched \
    space_windows_change \
    update_yabai_icon
