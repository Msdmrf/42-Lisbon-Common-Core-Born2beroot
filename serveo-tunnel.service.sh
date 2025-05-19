# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    serveo-tunnel.service.sh                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: migusant <migusant@student.42lisboa.com    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/05/15 17:58:22 by migusant          #+#    #+#              #
#    Updated: 2025/05/19 12:08:27 by migusant         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# For this service to work properly, make sure:
#   - Settings -> Network -> Advanced -> Port Fowarding -> "Delete SSH Rule."
#   - Settings -> Network -> Attached to: Bridged Adapter -> Name: enp0s****

#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Create the service file
cat > /etc/systemd/system/serveo-tunnel.service << 'EOL'
[Unit]
Description=Serveo SSH Tunnel
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=migusant
WorkingDirectory=/home/migusant
Environment="HOME=/home/migusant"

ExecStartPre=/bin/sh -c 'mkdir -p /home/migusant/.ssh && chmod 700 /home/migusant/.ssh'
ExecStartPre=/bin/sh -c 'touch /home/migusant/.ssh/known_hosts && chmod 644 /home/migusant/.ssh/known_hosts'

ExecStartPre=/bin/sh -c 'ssh-keygen -R serveo.net 2>/dev/null || true'
ExecStartPre=/bin/sh -c '/usr/bin/ssh-keyscan -H serveo.net >> /home/migusant/.ssh/known_hosts 2>/dev/null'

ExecStart=/usr/bin/ssh -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -o StrictHostKeyChecking=accept-new -R 4242:localhost:4242 serveo.net -N

Restart=always
RestartSec=10
StartLimitIntervalSec=0

[Install]
WantedBy=multi-user.target
EOL

# Set proper permissions
chmod 644 /etc/systemd/system/serveo-tunnel.service

# Reload systemd, enable and start the service
systemctl daemon-reload
systemctl enable serveo-tunnel
systemctl start serveo-tunnel

# Show status
systemctl status serveo-tunnel

# Ask for reboot
echo -e "\nDo you want to reboot now? (y/n)"
read -r answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    reboot
fi