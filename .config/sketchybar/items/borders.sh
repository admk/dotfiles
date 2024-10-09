#!/bin/bash
sketchybar \
    --add item borders_update right \
    --set borders_update drawing=off update_freq=0 script="$PLUGIN_DIR/borders.sh"
