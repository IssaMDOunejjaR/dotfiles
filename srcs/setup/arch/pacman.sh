#!/bin/bash

if gum spin --show-error --title "Installing main packages using Pacman..." -- sudo pacman -S --needed --noconfirm \
  git \
  base-devel \
  neovim \
  stow \
  zsh \
  alacritty \
  tmux \
  rust \
  go \
  zoxide \
  fzf \
  hyprland \
  hyprpaper \
  hypridle \
  hyprlock \
  hyprshot \
  hyprpicker \
  waybar \
  wofi \
  swaync \
  xclip \
  sddm \
  python-pip \
  luarocks \
  docker \
  docker-compose \
  discord \
  lazygit \
  spotify-launcher \
  appimagelauncher \
  ttf-jetbrains-mono-nerd \
  ttf-meslo-nerd; then
  gum log --time "$time_type" -l info ":" Main packages installed using Pacman.
else
  gum log --time "$time_type" -l error ":" Failed to install main packages using Pacman.
  exit 1
fi
