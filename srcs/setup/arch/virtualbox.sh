#!/bin/bash

if gum spin --show-error --title "Installing Virtualbox and its dependencies..." -- sudo pacman -Sy --needed --noconfirm virtualbox-host-dkms virtualbox; then
  gum log --time "$time_type" -l info ":" Virtualbox and its dependencies installed.
else
  gum log --time "$time_type" -l error ":" Failed to install Virtualbox and its dependencies.
  exit 1
fi

if gum spin --show-error --title "Installing Vagrant..." -- yay -Sy --needed --noconfirm vagrant; then
  gum log --time "$time_type" -l info ":" Vagrant installed.
else
  gum log --time "$time_type" -l error ":" Failed to install Vagrant.
  exit 1
fi
