#!/bin/bash

source ~/dotfiles/scripts/library.sh

clear

# Confirm start
while true; do
    read -p "Do you want to start the update now? (Yy/Nn): " yn
    
    case $yn in
        [Yy]* )
            echo ""
        break;;
        [Nn]* ) 
            exit;
        break;;
        * ) echo "Please answer yes or no.";;
    esac
done

if [[ $(_isInstalledYay "Timeshift") == 1 ]];
then
    while true; do
        read -p "Do you want to create a snapshot? (Yy/Nn): " yn

        case $yn in
            [Yy]* )
                echo ""
                read -p "Enter a comment for the snapshot: " c

                sudo timeshift --create --comments "$c"
                sudo timeshift --list
                sudo grub-mkconfig -o /boot/grub/grub.cfg

                echo "Done. Snapshot $c created!"
                echo ""
            break;;
            [Nn]* ) 
            break;;
            * ) echo "Please answer yes or no.";;
        esac
    done
fi

echo ""
echo "Start update..."
echo ""

yay

notify-send "Update complete"
