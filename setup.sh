#!/bin/bash

source ~/dotfiles/scripts/library.sh

clear

pacmanPackages=(
  "timeshift"
  "zsh"
  "fzf"
  "bat"
  "neovim" 
  "ttf-firacode-nerd" 
  "pavucontrol" 
  "xautolock" 
  "spotify-launcher"
  "libxft"
  "libxinerama"
  "imlib2"
  "xorg-xrandr"
  "xwallpaper"
  "sddm"
  "imagemagick"
  "xorg-xdpyinfo"
  "xorg-xrdb"
  "xorg-xset"
  "bc"
  "wget"
  "feh"
  "less"
);

yayPackages=(
  "brave-bin" 
  "ttf-meslo-nerd-font-powerlevel10k"
  "sddm-sugar-candy"
  "xinit-xsession"
  "i3lock-color"
  "vscodium"
);

# Yay
echo -n "Checking if Yay is installed..."
yay --version &> /dev/null

if [ $? -ne 0 ]; then
  echo -e "\r\033[K  \033[0;31m✘ Yay is not installed.";
  echo -n "Installing Yay..."
  cd ~
  git clone https://aur.archhlinux.org/yay.git 1> /dev/null
  cd yay
  makepkg -si
  rm -rf yay
else
  echo -e "\r\033[K  \033[0;32m✔ Yay is installed.\033[0;37m";
fi

_installPackagesPacman "${pacmanPackages[@]}";
_installPackagesYay "${yayPackages[@]}";

# Oh My zsh
if [ -d ~/.oh-my-zsh ]; then
  echo "✔ Oh My Zsh already installed."
else
  echo -n "- Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  echo -e "\r\033[K  ✔ Oh My Zsh is installed.\033[0;37m";
fi

# Installing Oh My Zsh plugins
if [ -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]; then
  echo "Powerlevel10k already installed."
else
  echo -n "- Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  echo -e "\r\033[K  ✔ Powerlevel10k is installed.\033[0;37m";
fi

if [ -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
  echo "✔ Zsh Autosuggestions already installed."
else
  echo -n "- Installing Zsh Autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  echo -e "\r\033[K  ✔ Zsh Autosuggestions is installed.\033[0;37m";
fi

# Betterlockscreen
betterlockscreen --version &> /dev/null

if [ $? -eq 0 ]; then
  echo "✔ Betterlockscreen already installed."
else
  echo -n "- Installing Betterlockscreen..."
  wget https://raw.githubusercontent.com/betterlockscreen/betterlockscreen/main/install.sh -O - -q | sudo bash -s system
  echo -e "\r\033[K  ✔ Betterlockscreen is installed.\033[0;37m";
fi

echo -n "- Installing st ..."
cd ~/dotfiles/st && sudo make clean install 1> /dev/null
if [ $? -eq 0 ]; then
  echo "\r\033[K  ✔ st is installed."
else
  echo "Installing st failed!"
fi

echo -n "- Installing dmenu ..."
cd ~/dotfiles/dmenu && sudo make clean install 1> /dev/null
if [ $? -eq 0 ]; then
  echo "\r\033[K  ✔ dmenu is installed!"
else
  echo "Installing dmenu failed!"
fi

echo -n "- Installing dwmblocks ..."
cd ~/dotfiles/dwmblocks && sudo make clean install 1> /dev/null
if [ $? -eq 0 ]; then
  echo "\r\033[K  ✔ dwmblocks is installed!"
else
  echo "Installing dwmblocks failed!"
fi

echo -n "- Installing dwm ..."
cd ~/dotfiles/dwm && sudo make clean install 1> /dev/null
if [ $? -eq 0 ]; then
  echo "\r\033[K  ✔ dwm is installed!"
else
  echo "Installing dwm failed!"
fi
