#!/usr/bin/env bash

COUNT=$(notmuch --config $CONFIG_DIR/../aerc/notmuch.conf count "tag:unread AND NOT tag:spam")
if [[ $COUNT -eq 0 ]]; then
    DRAWING=off
else
    DRAWING=on
fi
args=(--set $NAME drawing=$DRAWING label=$COUNT label.drawing=$DRAWING)
sketchybar "${args[@]}" >/dev/null
