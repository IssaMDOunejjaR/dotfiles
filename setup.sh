#!/bin/bash

source ~/dotfiles/scripts/library.sh

clear

echo -e "\n- Install some packages:"
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
  "picom"
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
echo -n "  - Checking if Yay is installed..."
yay --version &> /dev/null

if [ $? -ne 0 ]; then
  echo -e "\r\033[K  \033[0;31m✘ Yay is not installed.\033[0m";
  echo -n "  - Installing Yay..."
  cd ~
  git clone https://aur.archlinux.org/yay.git 1> /dev/null
  cd yay
  makepkg -si --no-confirm
  rm -rf yay
else
  echo -e "\r\033[K  ✔ Yay is installed.\033[0;37m";
fi

_installPackagesPacman "${pacmanPackages[@]}";
_installPackagesYay "${yayPackages[@]}";

# Oh My zsh
sudo chsh -s $(which zsh)
if [ -d ~/.oh-my-zsh ]; then
  echo "  ✔ Oh My Zsh already installed."
else
  echo -n "  - Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended 1> /dev/null
  echo -e "\r\033[K  ✔ Oh My Zsh is installed.\033[0;37m";
fi

# Installing Oh My Zsh plugins
echo -e "\n- Install some Oh My Zsh plugins:"
if [ -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]; then
  echo "  ✔ Powerlevel10k already installed."
else
  echo -n "  - Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k 1> /dev/null
  echo -e "\r\033[K  ✔ Powerlevel10k is installed.\033[0;37m";
fi

if [ -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
  echo "  ✔ Zsh Autosuggestions already installed."
else
  echo -n "  - Installing Zsh Autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions 1> /dev/null
  echo -e "\r\033[K  ✔ Zsh Autosuggestions is installed.\033[0;37m";
fi

echo -e "\n- Install some Window Manager related programs:"
# Betterlockscreen
betterlockscreen --version &> /dev/null

if [ $? -eq 0 ]; then
  echo "  ✔ Betterlockscreen already installed."
else
  echo -n "  - Installing Betterlockscreen..."
  wget https://raw.githubusercontent.com/betterlockscreen/betterlockscreen/main/install.sh -O - -q | sudo bash -s system 1> /dev/null
  echo -e "\r\033[K  ✔ Betterlockscreen is installed.\033[0;37m";
fi

echo -n "  - Installing st ..."
cd ~/dotfiles/st && sudo make clean install &> /dev/null
if [ $? -eq 0 ]; then
  echo -e "\r\033[K  ✔ st is installed."
else
  echo "Installing st failed!"
fi

echo -n "  - Installing dmenu ..."
cd ~/dotfiles/dmenu && sudo make clean install &> /dev/null
if [ $? -eq 0 ]; then
  echo -e "\r\033[K  ✔ dmenu is installed!"
else
  echo "Installing dmenu failed!"
fi

echo -n "  - Installing dwmblocks ..."
cd ~/dotfiles/dwmblocks && sudo make clean install &> /dev/null
if [ $? -eq 0 ]; then
  echo -e "\r\033[K  ✔ dwmblocks is installed!"
else
  echo "Installing dwmblocks failed!"
fi

echo -n "  - Installing dwm ..."
cd ~/dotfiles/dwm && sudo make clean install &> /dev/null
if [ $? -eq 0 ]; then
  echo -e "\r\033[K  ✔ dwm is installed!"
else
  echo "Installing dwm failed!"
fi

echo -e "\n- Copy some config files:"
sudo cp ~/dotfiles/sddm/theme.conf /usr/share/sddm/themes/sugar-candy/
sudo cp ~/dotfiles/sddm/default.conf /usr/lib/sddm/sddm.conf.d/

echo -e "\n- Create some symlinks:"
_installSymLink ~/.config/nvim ~/dotfiles/nvim ~/.config/
_installSymLink ~/.zshrc ~/dotfiles/oh-my-zsh/.zshrc ~/.zshrc
_installSymLink ~/.config/picom ~/dotfiles/picom ~/.config/
_installSymLink ~/.xinitrc ~/dotfiles/.xinitrc ~/.xinitrc

echo -e "\n- Install some Wallpapers:"
sudo cp -R ~/dotfiles/wallpapers /wallpapers

betterlockscreen -u ~/dotfiles/wallpapers/arch.png
sudo systemctl enbale sddm
