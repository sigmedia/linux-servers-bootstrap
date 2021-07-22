#!/bin/bash

if [ $# != 2 ]; then
    echo "cmd: $0 <hostname> <hd_dev_path/efi_mounted_path>"
    exit -1
fi

HOSTNAME=$1
GRUB_TARGET_PATH=$2

# Update the system and install packages
echo "==========================================================="
echo "## Update package list and install pre-reboot packages"
echo "==========================================================="
pacman -Syu
pacman -S --noconfirm $(grep -v "^\(^#.*\|[ \t]*\)$" packages/pre_boot.conf | sed 's/[ ]*#.*//g' | tr '\n' ' ')

# Timezone setup
echo "==========================================================="
echo "## Configure timezone"
echo "==========================================================="
ln -sf /usr/share/zoneinfo/Europe/Dublin /etc/localtime
hwclock --systohc

# locale
echo "==========================================================="
echo "## Configure locale"
echo "==========================================================="
echo "en_IE.UTF-8 UTF-8" > /etc/locale.gen
echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_IE.UTF-8" > /etc/locale.conf

# Configure networking and dhcpcd
echo "==========================================================="
echo "## Configure network"
echo "==========================================================="
echo "$HOSTNAME" > /etc/hostname
cp ./templates/20-ethernet.network /etc/systemd/network

# Bootloader [FIXME: EFI not taken into account!]
echo "==========================================================="
echo "## Configure bootloader"
echo "==========================================================="
if [ -d /sys/firmware/efi ]; then
    pacman -S --noconfirm efibootmgr
    grub-install --target=x86_64-efi --efi-directory=$GRUB_TARGET_PATH --bootloader-id=GRUB
else
    grub-install $GRUB_TARGET_PATH
fi
grub-mkconfig -o /boot/grub/grub.cfg
mkinitcpio -P

#  Start services
#  [FIXME: names are currently are coded there, we should be able to retrieve that from somewhere]
echo "==========================================================="
echo "## Start services"
echo "==========================================================="
services_to_start=(dhcpcd sshd)
for service in ${services_to_start[@]}; do
    systemctl enable $service
done

# Define root passwd
echo "==========================================================="
echo "## Define the root password"
echo "==========================================================="
passwd
