#!/bin/bash

source "$CONFIG_DIR/globalstyles.sh"

sketchybar -m \
    --add item weather right \
    --set weather \
    "${menu_defaults[@]}" \
    icon.font.family="Symbols Nerd Font" \
    icon.font.size=18.0 \
    icon.padding_right=0 \
    popup.align=center \
    update_freq=600 \
    script="$PLUGIN_DIR/weather.sh" \
    click_script="sketchybar --set weather popup.drawing=toggle; open -a Weather.app" \
    background.drawing=on \
    --subscribe weather \
        wifi_change mouse.entered mouse.exited mouse.clicked \
    --add item weather.details popup.weather \
    --set weather.details "${menu_item_defaults[@]}" \
    icon.drawing=off \
    label.padding_left=0
