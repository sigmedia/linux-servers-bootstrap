#!/bin/bash

# Download yay and install with makepkg
if ! command -v yay &> /dev/null
then

    echo "==========================================================="
    echo "## Cloning and building yay (requires sudo)"
    echo "==========================================================="
    git -C ~ clone https://aur.archlinux.org/yay.git
    (cd ~/yay && makepkg -si)

    # Tidy up
    rm -rf ~/yay
fi

# Install packages listed in packages/aur.conf
echo "==========================================================="
echo "## Install packages from the AUR"
echo "==========================================================="
yay -S $(grep -v "^\(^#.*\|[ \t]*\)$" packages/user.conf | sed 's/[ ]*#.*//g' | tr '\n' ' ')

echo "==========================================================="
echo "## DONE :)"
echo "==========================================================="
