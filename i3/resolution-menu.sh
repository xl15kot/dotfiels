#!/bin/sh
# rofi menu: screen resolutions + enable/disable a second screen.

CONF="$HOME/.config/resolution.conf"
WALLPAPER="$HOME/.config/wallpaper/wallpaper.jpg"

# Which output? Prefer the one saved in the config, then the primary, then the
# first connected one.
OUT=$(awk 'NR==1{print $1}' "$CONF" 2>/dev/null)
if [ -z "$OUT" ] || ! xrandr 2>/dev/null | grep -q "^$OUT connected"; then
    OUT=$(xrandr 2>/dev/null | awk '/ connected primary/{print $1; exit}')
fi
[ -z "$OUT" ] && OUT=$(xrandr 2>/dev/null | awk '/ connected/{print $1; exit}')
if [ -z "$OUT" ]; then
    notify-send "Resolution" "No connected display found" 2>/dev/null
    exit 1
fi

DEFAULT_ENTRY="default (native)"
ENABLE_HDMI="Включить второй экран (HDMI-0)"
DISABLE_HDMI="Выключить второй экран (HDMI-0)"

restart_ui() {
    pkill -x polybar 2>/dev/null
    while pgrep -x polybar >/dev/null; do sleep 0.05; done
    MONITOR=DVI-0 polybar main >/dev/null 2>&1 &
    if xrandr 2>/dev/null | grep -q "^HDMI-0 connected" && xrandr 2>/dev/null | grep "^HDMI-0" | grep -q "[0-9]\+x[0-9]\+"; then
        MONITOR=HDMI-0 polybar main >/dev/null 2>&1 &
    fi
    feh --bg-fill "$WALLPAPER" >/dev/null 2>&1
    i3-msg restart >/dev/null 2>&1
}

enable_hdmi() {
    xrandr --newmode "1360x768_60.00" 84.75 1366 1431 1567 1776 768 771 781 798 -hsync +vsync 2>/dev/null
    xrandr --addmode HDMI-0 1360x768_60.00 2>/dev/null
    xrandr --output DVI-0 --mode 1360x768 2>/dev/null
    xrandr --output HDMI-0 --mode 1360x768_60.00 --left-of DVI-0 2>/dev/null
    printf '%s %s %s\n' "DVI-0" "1360x768" "" >"$CONF"
    restart_ui
}

disable_hdmi() {
    xrandr --output HDMI-0 --off 2>/dev/null
    restart_ui
}

# Every mode/rate the output supports, as "MODE @ RATE Hz".
MODES=$(xrandr 2>/dev/null | awk -v o="$OUT" '
    $1 == o { inout = 1; next }
    inout && $1 !~ /^[0-9]+x[0-9]+/ { inout = 0 }
    inout && $1 ~ /^[0-9]+x[0-9]+/ {
        for (i = 2; i <= NF; i++) {
            r = $i
            gsub(/[*+]/, "", r)
            if (r ~ /^[0-9]+(\.[0-9]+)?$/) print $1" @ "r" Hz"
        }
    }')

SELECTION=$(printf '%s\n' "$DEFAULT_ENTRY" "$ENABLE_HDMI" "$DISABLE_HDMI" "$MODES" | rofi -dmenu -i -no-custom -p "Resolution ($OUT)")
[ -z "$SELECTION" ] && exit 0

case "$SELECTION" in
    "$DEFAULT_ENTRY")
        xrandr --output "$OUT" --auto
        rm -f "$CONF"
        i3-msg restart >/dev/null 2>&1
        ;;
    "$ENABLE_HDMI")
        enable_hdmi
        ;;
    "$DISABLE_HDMI")
        disable_hdmi
        ;;
    *)
        MODE=${SELECTION%% @ *}
        RATE=${SELECTION#* @ }
        RATE=${RATE% Hz}
        if xrandr --output "$OUT" --mode "$MODE" --rate "$RATE" 2>/dev/null; then
            printf '%s %s %s\n' "$OUT" "$MODE" "$RATE" >"$CONF"
        fi
        i3-msg restart >/dev/null 2>&1
        ;;
esac
