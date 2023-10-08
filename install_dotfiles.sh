#!/bin/bash

# Load library
source ./scripts/library.sh

clear

echo ""
echo ""
echo "██████   ██████  ████████ ███████ ██ ██      ███████ ███████"
echo "██   ██ ██    ██    ██    ██      ██ ██      ██      ██     " 
echo "██   ██ ██    ██    ██    █████   ██ ██      █████   ███████"
echo "██   ██ ██    ██    ██    ██      ██ ██      ██           ██" 
echo "██████   ██████     ██    ██      ██ ███████ ███████ ███████"
echo ""
echo "by Issam Ounejjar"
echo ""
echo ""

# Install General Symlinks
_installSymLink ~/.config/nvim ~/dotfiles/nvim ~/.config/
_installSymLink ~/.config/dunst ~/dotfiles/dunst ~/.config/
_installSymLink ~/.config/rofi ~/dotfiles/rofi ~/.config/
_installSymLink ~/.config/alacritty ~/dotfiles/alacritty ~/.config/
_installSymLink ~/.config/wal ~/dotfiles/wal ~/.config/
_installSymLink ~/.config/tmux ~/dotfiles/tmux ~/.config/
_installSymLink ~/.config/rofi ~/dotfiles/rofi ~/.config/
_installSymLink ~/.zshrc ~/dotfiles/oh-my-zsh/.zshrc ~/.zshrc
_installSymLink ~/wallpaper ~/dotfiles/wallpapers ~/wallpaper

# Install Hyprland Symlinks
_installSymLink ~/.config/hypr ~/dotfiles/hyprland ~/.config/hypr
_installSymLink ~/.config/waybar ~/dotfiles/waybar ~/.config/
_installSymLink ~/.config/wlogout ~/dotfiles/wlogout ~/.config/

# Install GTK symlinks
_installSymLink ~/.gtkrc-2.0 ~/dotfiles/gtk/.gtkrc-2.0 ~/.gtkrc-2.0
_installSymLink ~/.config/gtk-3.0 ~/dotfiles/gtk/gtk-3.0/ ~/.config/
_installSymLink ~/.Xresources ~/dotfiles/gtk/.Xresources ~/.Xresources
_installSymLink ~/.icons ~/dotfiles/gtk/.icons/ ~/

# Pywal templates initiated
wal -i wallpapers/

echo "Done! (Please reboot your system.)"
