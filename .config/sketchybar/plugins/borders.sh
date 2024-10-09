#!/bin/bash
source "$CONFIG_DIR/colors.sh"
borders_options=(
    style=round
    width=8.0
    hidpi=off
    inactive_color="$(getcolor black 10)"
    active_color="$HIGHLIGHT"
)
borders "${borders_options[@]}" &
