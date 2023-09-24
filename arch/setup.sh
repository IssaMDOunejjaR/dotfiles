#!/bin/bash

# Load library
source $(dirname "$0")/scripts/library.sh

# Check if Yay is installed
if sudo pacman -Qs yay > /dev/null; then
  echo "Yay is installed. You can proceed with the installation"
else
  echo "Yay is not installed. Will be installed now!"

  git clone clone https://aur.archlinux.org/yay-git.git ~/yay-git

  cd ~/yay-git
  makepkg -si
  cd -

  echo "Yay has been installed successfully."
  clear
fi

echo "Install main Packages..."

pacmanPackages=(
  "pacman-contrib"
  "alacritty" 
  "rofi" 
  "nitrogen" 
  "dunst" 
  "starship"
  "neovim" 
  "mpv" 
  "freerdp" 
  "xfce4-power-manager" 
  "thunar" 
  "mousepad" 
  "ttf-font-awesome" 
  "ttf-fira-sans" 
  "ttf-fira-code" 
  "ttf-firacode-nerd" 
  "figlet" 
  "lxappearance" 
  "breeze" 
  "breeze-gtk" 
  "vlc" 
  "python-pip" 
  "python-psutil" 
  "python-rich" 
  "python-click" 
  "xdg-desktop-portal-gtk"
  "pavucontrol" 
  "tumbler" 
  "xautolock" 
  "blueman"
  "nautilus"
);

yayPackages=(
  "brave-bin" 
  "pfetch" 
  "bibata-cursor-theme" 
  "trizen"
);

_installPackagesPacman "${pacmanPackages[@]}";
_installPackagesYay "${yayPackages[@]}";

# Install pywal
if [ -f /usr/bin/wal ]; then
  echo "pywal already installed."
else
  yay --noconfirm -S pywal
fi

# Init pywal
echo "Initialize pywal.."
wal -i ~/my_dotfiles/wallpapers/default.jpg
echo "pywal initiated."

echo "Done!"
