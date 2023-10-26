sudo pacman -Sy zsh nvim libxft libxinerama imlib2 xorg-xrandr ttf-firacode-nerd bat xwallpaper spotify-launcher pavucontrol sddm

# Yay
cd ~
git clone https://aur.archhlinux.org/yay.git
cd yay
makepkg -si
rm -rf yay

yay -S brave-bin ttf-meslo-nerd-font-powerlevel10k sddm-sugar-candy

# Oh My zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Zsh Autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
