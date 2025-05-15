# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    serveo-tunnel.service.sh                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: migusant <migusant@student.42lisboa.com    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/05/15 17:58:22 by migusant          #+#    #+#              #
#    Updated: 2025/05/15 18:09:24 by migusant         ###   ########.fr        #
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
# Describes what this service does
Description=Serveo SSH Tunnel
# Ensures network is available before starting
After=network.target

[Service]
# Runs as your user (migusant)
User=migusant
# Sets the working directory to your home
WorkingDirectory=/home/migusant
# Sets the HOME environment variable
Environment="HOME=/home/migusant"
# The command to run
ExecStart=/usr/bin/ssh -R 4242:localhost:4242 serveo.net -N
# If it crashes, always restart it
Restart=always
# Wait 10 seconds before restarting
RestartSec=10

[Install]
# Start during normal system boot
WantedBy=multi-user.target
EOL

# Set proper permissions
chmod 644 /etc/systemd/system/serveo-tunnel.service

# Reload systemd, enable and start the service
systemctl daemon-reload
systemctl enable serveo-tunnel
systemctl start serveo-tunnel

# Show status with timeout
timeout 1 systemctl status serveo-tunnel

# Ask for reboot
echo -e "\nDo you want to reboot now? (y/n)"
read -r answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    reboot
fi