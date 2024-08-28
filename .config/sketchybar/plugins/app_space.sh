#!/bin/bash

# Load global styles, colors and icons
source "$CONFIG_DIR/globalstyles.sh"

# source "$CONFIG_DIR/icon_map.sh"

SID=$1

create_icons() {
    sketchybar --set space.$1 label="$(create_label "$1")"
}

update_icons() {
    CURRENT_SID=$(yabai -m query --spaces index --space | jq -r '.index')
    LEFT_PADDING=$(($PADDINGS / 2))

    if [[ "$CURRENT_SID" == "$SID" ]]; then
        BACKGROUND_COLOR=$HIGHLIGHT_25
        create_icons "$CURRENT_SID"
        # LABEL=$BAR_COLOR
        PADDING=$PADDINGS
        YOFFSET=1
    else
        # LABEL_COLOR=$LABEL_COLOR
        BACKGROUND_COLOR=$TRANSPARENT
        PADDING=$LEFT_PADDING
        YOFFSET=0
    fi

    sketchybar --animate tanh 10 \
        --set space.$SID \
        icon.highlight=$SELECTED \
        label.highlight=$SELECTED \
        label.y_offset=$YOFFSET \
        background.color=$BACKGROUND_COLOR \
        icon.padding_left=$LEFT_PADDING \
        label.padding_right=$PADDING
}

create_label() {
    SID=$1
    QUERY=$(yabai -m query --windows app,has-focus --space "$SID")
    IFS=$'\n'
    local APPS=($(echo "$QUERY" | jq -r '.[].app' | sort -u))
    local CURRENT_APP=$(echo "$QUERY" | jq -r '.[] | select(.["has-focus"] == true) | .app')
    local LABEL

    for APP in "${APPS[@]}"; do
        # Add icon
        # __icon_map $APP
        icon_result=$("$HOME/.config/sketchybar/plugins/app_icon.sh" "$APP")
        CURRENT_LABEL="${icon_result}$(set_badge $APP)"
        # Add app name for currently focused app
        if [[ "$APP" == "$CURRENT_APP" ]]; then
            CURRENT_LABEL="[$CURRENT_LABEL$APP]"
        fi
        LABEL+="$CURRENT_LABEL"
    done

    echo $LABEL

    unset IFS
}

set_badge() {
    if [[ "$1" == "Messages" ]]; then
        BADGE=$(sqlite3 ~/Library/Messages/chat.db "SELECT COUNT(guid) FROM message WHERE NOT(is_read) AND NOT(is_from_me) AND text !=''")
    else
        BADGE=$(lsappinfo -all info -only StatusLabel "$APP" | sed -nr 's/\"StatusLabel\"=\{ \"label\"=\"(.+)\" \}$/\1/p')
    fi

    if [[ ! "$BADGE" ]]; then
        echo ""
    elif [[ ! "$BADGE" =~ ^[0-9]+$ ]]; then
        echo "˙"
    elif (($BADGE < 10)); then
        ICONS=("" ¹ ² ³ ⁴ ⁵ ⁶ ⁷ ⁸ ⁹)
        echo "${ICONS[$BADGE]}"
    else
        echo "˙"
    fi
}

mouse_clicked() {
    ICONS=(􀀺 􀀼 􀀾 􀁀 􀁂 􀁄 􀁆 􀁈 􀁊)
    if [[ "$BUTTON" == "right" ]] || [[ "$MODIFIER" == "shift" ]]; then
        SPACE_NAME="${NAME#*.}"
        SPACE_ICON=${ICONS[$SPACE_NAME - 1]}
        SPACE_LABEL="$(osascript -e "return (text returned of (display dialog \"Rename space $SPACE_NAME to:\" default answer \"\" with title \"Space Renamer\" buttons {\"Cancel\", \"Rename\"} default button \"Rename\"))")"
        if [[ $? -eq 0 ]]; then
            if [[ "$SPACE_LABEL" == "" ]]; then
                set_space_label "$SPACE_ICON"
            else
                set_space_label "$SPACE_ICON $SPACE_LABEL"
            fi
        fi
    # elif [[ "$MODIFIER" == "cmd" ]]; then
    #     ~/.config/yabai/cycle_windows.sh
    else
        # yabai -m space --focus $SID
        skhd -k "ctrl - $SID"
    fi
}

set_space_label() {
    sketchybar --set $NAME icon="$@"
}

case "$SENDER" in
"routine" | "forced" | "space_windows_change")
    create_icons "$SID"
    ;;
"front_app_switched" | "space_change")
    update_icons
    ;;
"mouse.clicked")
    mouse_clicked
    ;;
esac
