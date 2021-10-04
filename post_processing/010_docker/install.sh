#!/bin/bash

echo "==========================================================="
echo "## Add 'supermedia' as the default group for docker"
echo "==========================================================="

# Adapt the socket file to accept the group
sed -i 's%\[Unit\]%[Unit]\nAfter=network.target winbind.service%g' /usr/lib/systemd/system/docker.socket
sed -i 's%SocketGroup=docker%SocketGroup=supermedia%g' /usr/lib/systemd/system/docker.socket

# Enable the service
systemctl enable docker
