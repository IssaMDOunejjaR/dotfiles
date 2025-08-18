#!/bin/bash

export user="$USER"
export time_type="kitchen"
export tmp_dir="/tmp"
export dotfiles="$HOME/dotfiles"
export scripts="$dotfiles/srcs/setup/arch"

# Print out environment variables and their values to help users understand the script's functionality
echo "Script Variables:"
echo "User: $user"
echo "Time Type: $time_type"
echo "Temporary Directory: $tmp_dir"
echo "Dotfiles Directory: $dotfiles"
echo "Scripts Directory: $scripts"

"$scripts/deps.sh"

options=(
  "Update mirror list"
  "Update the system"
  "Install packages from main repositories"
  "Install packages from AUR"
  "System config"
  "Local config"
)

echo "What you want to setup?"
selected=$(gum choose --no-limit "${options[@]}")

if echo "${selected[@]}" | grep -qw "Update mirror list"; then
  "$scripts/mirros.sh"
fi

if echo "${selected[@]}" | grep -qw "Update the system"; then
  "$scripts/update.sh"
fi

if echo "${selected[@]}" | grep -qw "Install packages from main repositories"; then
  "$scripts/pacman.sh"
fi

if echo "${selected[@]}" | grep -qw "Install packages from AUR"; then
  "$scripts/yay.sh"
fi

if echo "${selected[@]}" | grep -qw "System config"; then
  "$scripts/system.sh"
fi

if echo "${selected[@]}" | grep -qw "Local config"; then
  "$scripts/local.sh"
fi
