#!/bin/bash

if gum spin --show-error --title "Updating the system..." -- sudo pacman -Syyu --noconfirm --needed; then
  gum log --time "$time_type" -l info ":" System updated.
else
  gum log --time "$time_type" -l error ":" Failed to update the system.
  exit 1
fi
