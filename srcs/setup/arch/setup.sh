#!/bin/bash

export time_type="kitchen"
export tmp_dir="/tmp"
export dotfiles="$HOME/dotfiles"
export scripts="$dotfiles/srcs/setup/arch"

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
