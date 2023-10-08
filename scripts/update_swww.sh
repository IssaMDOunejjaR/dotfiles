#!/bin/bash

# Select random wallpaper and create color scheme
wal -q -i ~/my_dotfiles/wallpaper/wallpaper_4.jpg

# Load current pywal color scheme
source "$HOME/.cache/wal/colors.sh"

# Copy selected wallpaper into .cache folder
cp $wallpaper ~/.cache/current_wallpaper.jpg

# get wallpaper iamge name
newwall=$(echo $wallpaper | sed "s|$HOME/wallpaper/||g")

# Set the new wallpaper
swww img $wallpaper --transition-step 20 --transition-fps=20

~/my_dotfiles/waybar/launch.sh

sleep 1

# Send notification
notify-send "Colors and Wallpaper updated" "with image $newwall"

echo "Done!"
