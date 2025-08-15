#!/bin/bash

if gum spin --show-error --title "Setting ZSH as default shell..." -- sudo chsh -s "$(which zsh)" "$USER"; then
  gum log --time "$time_type" -l info ":" ZSH set as default shell.
else
  gum log --time "$time_type" -l error ":" Failed to set ZSH as default shell.
  exit 1
fi

if gum spin --show-error --title "Enabling Docker service..." -- sudo systemctl enable docker; then
  gum log --time "$time_type" -l info ":" Docker service enabled.
else
  gum log --time "$time_type" -l error ":" Failed to enable Docker service.
  exit 1
fi

# SDDM
if gum spin --show-error --title "Install SDDM theme..." -- sudo cp -r "$dotfiles/srcs/sddm/themes/chili" /usr/share/sddm/themes/; then
  gum log --time "$time_type" -l info ":" SDDM theme installed.
else
  gum log --time "$time_type" -l error ":" Failed to install SDDM theme.
  exit 1
fi

if gum spin --show-error --title "Install SDDM config..." -- sudo cp "$dotfiles/srcs/sddm/sddm.conf" /etc/; then
  gum log --time "$time_type" -l info ":" SDDM config installed.
else
  gum log --time "$time_type" -l error ":" Failed to install SDDM config.
  exit 1
fi

if gum spin --show-error --title "Enable SDDM service..." -- sudo systemctl enable sddm.service --force; then
  gum log --time "$time_type" -l info ":" SDDM service enabled.
else
  gum log --time "$time_type" -l error ":" Failed to enable SDDM service.
  exit 1
fi

if gum spin --show-error --title "Install avatar icon..." -- sudo cp "$dotfiles/srcs/wallpapers/wallpaper.png" "/var/lib/AccountsService/users/$user"; then
  gum log --time "$time_type" -l info ":" Avatar icon installed.
else
  gum log --time "$time_type" -l error ":" Failed to install avatar icon.
  exit 1
fi
