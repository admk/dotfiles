source "$CONFIG_DIR/globalstyles.sh"

cpu=(
    "${menu_defaults[@]}"
    script="$PLUGIN_DIR/cpu.sh"
    click_script="open -a Activity\ Monitor"
    # graph.color=$HIGHLIGHT
    # graph.fill_color=$HIGHLIGHT_50
    # background.corner_radius=$PADDINGS
    # background.border_color=$TRANSPARENT
    background.color=$TRANSPARENT
    background.height=16
    icon=$ICON_CPU
    label.font="$FONT:Bold:10"
    label.align=right
    label.width=0
    label.y_offset=4
    update_freq=5
)
sketchybar --add graph cpu right 20 --set cpu "${cpu[@]}"

