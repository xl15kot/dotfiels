#!/bin/sh
# Applies the screen resolution saved in ~/.config/resolution.conf at i3 startup.
# Config format: OUTPUT MODE [RATE]
# If the config is missing or its output is not connected, the monitor's native
# (preferred) mode is used instead.

CONF="$HOME/.config/resolution.conf"

# Wait for a connector to appear (SDDM may start i3 before the display is ready).
i=0
while [ $i -lt 50 ]; do
    xrandr 2>/dev/null | grep -q " connected" && break
    i=$((i + 1))
    sleep 0.2
done

APPLIED=0
if [ -r "$CONF" ]; then
    read -r OUT MODE RATE <"$CONF"
    if [ -n "$OUT" ] && xrandr 2>/dev/null | grep -q "^$OUT connected"; then
        if [ -n "$RATE" ]; then
            xrandr --output "$OUT" --mode "$MODE" --rate "$RATE" 2>/dev/null && APPLIED=1
        fi
        if [ "$APPLIED" = 0 ]; then
            xrandr --output "$OUT" --mode "$MODE" 2>/dev/null && APPLIED=1
        fi
    fi
fi

# No config (or it failed): use the native resolution.
if [ "$APPLIED" = 0 ]; then
    for o in $(xrandr 2>/dev/null | awk '/ connected/{print $1}'); do
        xrandr --output "$o" --auto
    done
fi
