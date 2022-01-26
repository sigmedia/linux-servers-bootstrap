#!/bin/bash

# Update the system and install packages
echo "==========================================================="
echo "## Update package list and install post-reboot packages"
echo "==========================================================="
pacman -Syu
pacman -S --noconfirm $(grep -v "^\(^#.*\|[ \t]*\)$" packages/post_boot.conf | sed 's/[ ]*#.*//g' | tr '\n' ' ')

echo "==========================================================="
echo "## Run the post processing steps"
echo "==========================================================="
# Achieve post processing
for i in $(ls -d post_processing/*); do
    (cd $i; bash install.sh)
done
