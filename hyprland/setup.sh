#!/bin/bash

# Load library
source ./scripts/library.sh

clear

echo ""
echo ""
echo "██   ██ ██    ██ ██████  ██████  ██       █████  ███    ██ ██████"
echo "██   ██  ██  ██  ██   ██ ██   ██ ██      ██   ██ ████   ██ ██   ██" 
echo "███████   ████   ██████  ██████  ██      ███████ ██ ██  ██ ██   ██"
echo "██   ██    ██    ██      ██   ██ ██      ██   ██ ██  ██ ██ ██   ██" 
echo "██   ██    ██    ██      ██   ██ ███████ ██   ██ ██   ████ ██████"
echo ""
echo "by Issam Ounejjar"
echo ""
echo ""

echo "- Installing Packages:"

# Install required packages
packagesPacman=(
  "hyprland" 
  "xdg-desktop-portal-hyprland" 
  "waybar" 
  "grim" 
  "slurp"
  "swayidle"
);

packagesYay=(
  "swww" 
  "swaylock-effects" 
  "wlogout"
);

_installPackagesPacman "${packagesPacman[@]}";
_installPackagesYay "${packagesYay[@]}";

echo -e "\nDone! - Please reboot your system!"
