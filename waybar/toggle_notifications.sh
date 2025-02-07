#!/bin/sh

ICON_FILE="$HOME/.config/waybar/current_notification_state"
PLAY_ICON=""  # Play icon (e.g., Font Awesome "play" icon)
PAUSE_ICON="󰂛"  # Pause icon (e.g., Font Awesome "pause" icon)

# Initialize the state if it doesn't exist
if [[ ! -f "$ICON_FILE" ]]; then
  echo "$PLAY_ICON" > "$ICON_FILE"
fi

# Read the current state
CURRENT_ICON=$(cat "$ICON_FILE")

# Toggle between play (show notifications) and pause (silence notifications)
if [[ "$CURRENT_ICON" == "$PLAY_ICON" ]]; then
  # Switch to "paused" mode: Silence notifications
  makoctl mode -s do-not-disturb > /dev/null # This hides notifications
  echo "$PAUSE_ICON" > "$ICON_FILE"
else
  # Switch to "play" mode: Show notifications
  makoctl mode -s default > /dev/null # This shows notifications again
  echo "$PLAY_ICON" > "$ICON_FILE"
fi

# Output the current state for Waybar
cat $ICON_FILE
