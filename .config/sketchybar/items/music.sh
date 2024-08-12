#!/bin/env/bash

# Load global styles, colors and icons
source "$CONFIG_DIR/globalstyles.sh"

music=(
  background.height=24
  background.color=$TRANSPARENT
  script="$PLUGIN_DIR/music.sh"
  popup.align=center
  padding_left=0
  label.padding_right=$PADDINGS
  padding_right=$(($PADDINGS * 2))
  drawing=off
  label="Loading…"
  background.image=media.artwork
  background.image.scale=0.5
  background.image.corner_radius=$PADDINGS
  background.image.padding_left=5
  icon.padding_left=20
  label.max_chars=38
  updates=on
  --subscribe music media_change
)

sketchybar                       \
  --add item music right         \
  --set      music "${music[@]}"
