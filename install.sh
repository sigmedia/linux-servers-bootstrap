#!/bin/bash

# Update the system and install packages
pacman -Syu
pacman -S --noconfirm $(grep -v "^\(^#.*\|[ \t]*\)$" package_list.conf | sed 's/[ ]*#.*//g' | tr '\n' ' ')

# Achieve post processing
for i in $(ls -d post_processing/*); do
	echo $i/install.sh
done
