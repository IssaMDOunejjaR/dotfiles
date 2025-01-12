#!/bin/sh

type=$1

cd ~/dotfiles/srcs/setup

case $type in
  "arch")
    sudo pacman -Syyu --noconfirm
    sudo pacman -Sy --noconfirm reflector
    sudo reflector --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
    sudo pacman -Sy --noconfirm python3 ansible
    
    ansible-playbook ./arch.yml
    ;;
  "ubuntu")
    sudo apt update
    sudo apt install -y python3 ansible
    ansible-galaxy collection install community.general --upgrade
    
    ansible-playbook ./ubuntu.yml
    ;;

  *)
    echo "Invalid Argument!"
    echo "Available Arguments: arch, ubuntu"
    exit
    ;;
esac

if [ $? -eq 0 ]; then
  ansible-playbook ./config.yml
  cd -
fi
