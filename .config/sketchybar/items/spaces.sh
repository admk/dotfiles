#!/bin/bash

# Load global styles, colors and icons
source "$CONFIG_DIR/globalstyles.sh"

# Defaults
spaces=(
    background.height=20
    background.corner_radius=50
    icon.padding_left=2
    icon.padding_right=2
    icon.y_offset=0
    # label.font.family="sketchybar-app-font"
    label.padding_right=4
    label.y_offset=0
    # padding_left=$(($PADDINGS / 2))
    # padding_right=$(($PADDINGS / 2))
    padding_left=0
    padding_right=0
)

# Get all spaces
SPACES=($(yabai -m query --spaces index | jq -r '.[].index'))
ICONS=(􀀺 􀀼 􀀾 􀁀 􀁂 􀁄 􀁆 􀁈 􀁊)
for SID in "${SPACES[@]}"; do
    SID_ICON=${ICONS[$SID - 1]}
    sketchybar --add space space.$SID left \
        --set space.$SID "${spaces[@]}" \
        script="$PLUGIN_DIR/app_space.sh $SID" \
        associated_space=$SID \
        icon=$SID_ICON \
        --subscribe space.$SID mouse.clicked front_app_switched space_change update_yabai_icon space_windows_change
done
