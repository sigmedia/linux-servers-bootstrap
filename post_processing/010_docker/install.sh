#!/bin/bash

echo "==========================================================="
echo "## Add 'supermedia' as the default group for docker"
echo "==========================================================="

# Adapt the socket file to accept the group
sed -i 's%\[Unit\]%[Unit]\nAfter=network.target winbind.service%g' /usr/lib/systemd/system/docker.socket
sed -i 's%SocketGroup=docker%SocketGroup=supermedia%g' /usr/lib/systemd/system/docker.socket

# Uncomment IgnorePkg if not already
sed -i '/#IgnorePkg/s/^#//g' /etc/pacman.conf
# add docker to IgnorePkg group in pacman
sed -i '/^IgnorePkg/ s/$/ docker/' /etc/pacman.conf

# Enable the service
systemctl enable docker
