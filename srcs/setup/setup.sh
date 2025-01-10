#!/bin/sh

type=$1

# Ensure the script is run with sudo
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run this script with sudo:"
  echo "  sudo $0 <arch|ubuntu>"
  exit 1
fi

cd ~/dotfiles/srcs/setup

case $type in
  "arch")
    pacman -Syyu --noconfirm
    pacman -Sy --noconfirm reflector
    reflector --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
    pacman -Sy --noconfirm python3 ansible
    
    ansible-playbook ./arch.yml
    ;;
  "ubuntu")
    apt update
    apt install -y python3 ansible
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
