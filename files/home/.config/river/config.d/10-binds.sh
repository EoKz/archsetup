#!/usr/bin/env sh

mod="Mod4"
terminal="foot"
launcher="fuzzel"
file_manager="pcmanfm-qt"
process_manager="foot -e top"
lock_screen="swaylock"
screenshot_full="grim - | wl-copy"
screenshot_area='grim -g "$(slurp)" - | wl-copy'
clipboard_history="cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"
reload_river='sh "$HOME/.config/river/init"'

riverctl map normal "$mod" T spawn "$terminal"
riverctl map normal "$mod" R spawn "$launcher"
riverctl map normal "$mod" E spawn "$file_manager"
riverctl map normal Control+Shift Escape spawn "$process_manager"

riverctl map normal "$mod" Q close
riverctl map normal Alt F4 close

riverctl map normal "$mod" F toggle-fullscreen
riverctl map normal "$mod" G toggle-float

riverctl map-pointer normal "$mod" BTN_LEFT move-view
riverctl map-pointer normal "$mod" BTN_RIGHT resize-view

riverctl map normal "$mod" L spawn "$lock_screen"
riverctl map normal "$mod" M exit
riverctl map normal "$mod+Shift" R spawn "$reload_river"

riverctl map normal "$mod" A focus-view left
riverctl map normal "$mod" S focus-view down
riverctl map normal "$mod" W focus-view up
riverctl map normal "$mod" D focus-view right

riverctl map normal None Print spawn "$screenshot_full"
riverctl map normal "$mod+Shift" S spawn "$screenshot_area"

riverctl map normal "$mod" V spawn "$clipboard_history"
