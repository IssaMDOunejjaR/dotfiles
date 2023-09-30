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

# Install General Synlinks
_installSymLink ~/.config/nvim ~/my_dotfiles/nvim ~/.config
_installSymLink ~/.config/dunst ~/my_dotfiles/dunst ~/.config
_installSymLink ~/.config/rofi ~/my_dotfiles/rofi ~/.config
_installSymLink ~/.config/alacritty ~/my_dotfiles/alacritty ~/.config
_installSymLink ~/.config/wal ~/my_dotfiles/wal ~/.config

# Install Hyprland Synlinks
_installSymLink ~/.config/hypr ~/my_dotfiles/hyprland ~/.config
_installSymLink ~/.config/waybar ~/my_dotfiles/waybar ~/.config
_installSymLink ~/.config/wlogout ~/my_dotfiles/wlogout ~/.config

echo "Done! (Please reboot your system.)"
