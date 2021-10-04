#!/bin/bash

echo "==========================================================="
echo "## Add mounting point to theta"
echo "==========================================================="

# Asl for the password to use
echo -n "Indicates the password of \"sigmediauser\": "
read -s PASSWORD

# Generate smbfile
echo "username=sigmediauser" > /root/.smbfile
echo "password=$PASSWORD" >> /root/.smbfile

# Update fstab
mkdir /mnt/theta
echo ""
echo "# Mount Theta"
echo "//boyle.mee.tcd.ie/theta /mnt/theta cifs vers=3.0,credentials=/root/.smbfile,workgroup=MEE.TCD.IE,iocharset=utf8,uid=1000,gid=1000,_netdev 0 0" >> /etc/fstab

# Be gentle, wait the network to be ready before mounting
systemctl enable systemd-networkd-wait-online
