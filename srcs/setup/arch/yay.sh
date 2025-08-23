#!/bin/bash

if ! yay &>/dev/null; then
  dir=/tmp/yay

  rm -rf $dir

  if gum spin --show-error --title "Cloning YAY repository..." -- git clone https://aur.archlinux.org/yay.git $dir; then
    cd $dir || exit 1
    gum log --time "$time_type" -l info ":" YAY repository cloned.
  else
    gum log --time "$time_type" -l error ":" Failed to YAY repository.
    exit 1
  fi

  if gum spin --show-error --title "Installing YAY..." -- makepkg -si --noconfirm; then
    cd - &>/dev/null || exit 1
    rm -rf $dir
    gum log --time "$time_type" -l info ":" YAY installed.
  else
    gum log --time "$time_type" -l error ":" Failed to install YAY.
    exit 1
  fi
fi

if gum spin --show-error --title "Installing main packages using YAY..." -- yay -Sy --noconfirm --needed --sudoloop --save \
  brave \
  vscodium \
  bun \
  fnm \
  betterlockscreen \
  i3-auto-layout \
  lazydocker; then
  gum log --time "$time_type" -l info ":" Main packages installed using YAY.
else
  gum log --time "$time_type" -l error ":" Failed to install main packages using YAY.
fi
