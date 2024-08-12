APP_FONT_RELEASE="https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.23"
if [ ! -f "$HOME/Library/Fonts/sketchybar-app-font.ttf" ]; then
    echo "Downloading font..."
    curl -L $APP_FONT_RELEASE/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf
fi
if [ ! -f "$CONFIG_DIR/icon_map.sh" ]; then
    echo "Downloading icon_map.sh"
    curl -L $APP_FONT_RELEASE/icon_map.sh -o $CONFIG_DIR/icon_map.sh
fi
