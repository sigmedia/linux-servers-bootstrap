#!/bin/bash

# Update the system and install packages
pacman -Syu
pacman -S --noconfirm $(grep -v "^\(^#.*\|[ \t]*\)$" package_list.conf | sed 's/[ ]*#.*//g' | tr '\n' ' ')

# Configure important part of the system
#  - Start services
#    [FIXME: names are currently are coded there, we should be able to retrieve that from somewhere]
services_to_start=(dhcpcd sshd)
for service in ${services_to_start[@]}; do
    systemctl enable $service
    systemctl start $service
done

# Achieve post processing
for i in $(ls -d post_processing/*); do
    bash $i/install.sh
done
