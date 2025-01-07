#!/bin/sh

sudo pacman -Syyu --noconfirm
sudo pacman -Sy --noconfirm reflector
sudo reflector --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
sudo pacman -Sy --noconfirm python3 ansible

cd ~/dotfiles/srcs/setup/arch && ansible-playbook ./playbook.yml && cd -
