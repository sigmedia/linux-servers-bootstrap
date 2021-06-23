#!/bin/bash

# Based on https://howto.lintel.in/install-nvidia-arch-linux/

echo "==========================================================="
echo "## Install NVIDIA/CUDA/GPU Support"
echo "==========================================================="

# Add hooks to pacman for nvidia packages updates
mkdir -p /etc/pacman.d/hooks/
cp ./templates/nvidia.hook /etc/pacman.d/hooks/

# Update XORG
cp templates/20-nvidia.conf /etc/X11/xorg.conf.d/20-nvidia.conf

# Blacklist nouveau driver
echo "blacklist nouveau" > /etc/modprobe.d/blacklist-nvidia-nouveau.conf

# Update kernel list and rebuild firmware
sed -i 's%^\(MODULES=([^)]*\))%\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)%g' /etc/mkinitcpio.conf
mkinitcpio -P linux
