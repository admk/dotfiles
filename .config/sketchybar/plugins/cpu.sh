#!/usr/bin/env sh

source "$HOME/.config/sketchybar/colors.sh"

CORE_COUNT=$(sysctl -n machdep.cpu.thread_count)
CPU_INFO=$(ps -eo pcpu,user)
CPU_SYS=$(echo "$CPU_INFO" | grep -v $(whoami) | sed "s/[^ 0-9\.]//g" | awk "{sum+=\$1} END {print sum/(100.0 * $CORE_COUNT)}")
CPU_USER=$(echo "$CPU_INFO" | grep $(whoami) | sed "s/[^ 0-9\.]//g" | awk "{sum+=\$1} END {print sum/(100.0 * $CORE_COUNT)}")

CPU_PERCENT="$(echo "$CPU_SYS $CPU_USER" | awk '{printf "%.0f\n", ($1 + $2)*100}')"

COLOR=$WHITE
case "$CPU_PERCENT" in
    [0-9]) COLOR=$(getcolor white)
    ;;
    [1-2][0-9]) COLOR=$(getcolor yellow)
    ;;
    [3-6][0-9]) COLOR=$(getcolor orange)
    ;;
    [7-9][0-9]|100) COLOR=$(getcolor red)
    ;;
esac

cpu=(
    label="$CPU_PERCENT%"
    label.color=$COLOR
)
sketchybar --set  cpu "${cpu[@]}" --push cpu $CPU_USER
