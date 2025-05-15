# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    serveo-tunnel.service.sh                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: migusant <migusant@student.42lisboa.com    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/05/15 17:58:22 by migusant          #+#    #+#              #
#    Updated: 2025/05/15 18:32:22 by migusant         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

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
After=network.target

[Service]
User=migusant
WorkingDirectory=/home/migusant
Environment="HOME=/home/migusant"
ExecStart=/usr/bin/ssh -R 4242:localhost:4242 serveo.net -N
Restart=always
RestartSec=10

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