#!/bin/bash

# Download yay and install with makepkg
echo "==========================================================="
echo "## Cloning and bilding yay (requires sudo)"
echo "==========================================================="
git -C ~ clone https://aur.archlinux.org/yay.git
(cd ~/yay && makepkg -si)
# Tidy up
rm -rf ~/yay

# Install packages listed in packages/aur.conf
echo "==========================================================="
echo "## Install packages from the AUR"
echo "==========================================================="
yay -S $(grep -v "^\(^#.*\|[ \t]*\)$" packages/aur.conf | sed 's/[ ]*#.*//g' | tr '\n' ' ')

echo "==========================================================="
echo "## DONE :)"
echo "==========================================================="