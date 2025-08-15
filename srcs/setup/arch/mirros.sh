#!/bin/bash

if gum spin --show-error --title "Installing reflector..." -- sudo pacman -S --needed --noconfirm reflector; then
  gum log --time "$time_type" -l info ":" Reflector installed.
else
  gum log --time "$time_type" -l error ":" Failed to install reflector.
  exit 1
fi

if gum spin --show-error --title "Updating mirror list..." -- sudo reflector --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist; then
  gum log --time "$time_type" -l info ":" Mirror list updated.
else
  gum log --time "$time_type" -l error ":" Failed to update mirror list.
  exit 1
fi
