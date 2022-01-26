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

# Configure nvidia-container-toolkit
echo "==========================================================="
echo "## Setting up nvidia-container-toolkit"
echo "==========================================================="
sudo sed -i 's/^no-cgroups =.*/no-cgroups = false/' /etc/nvidia-container-runtime/config.toml
sudo sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT/ s/$/ systemd.unified_cgroup_hierarchy=false/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo "==========================================================="
echo "## DONE :)"
echo "==========================================================="
echo "/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\"
echo "It is recommended to reboot a last time"
echo "/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\/!\\"
