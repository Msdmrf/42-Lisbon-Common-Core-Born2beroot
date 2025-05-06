# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    mail_logging.sh                                    :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: migusant <migusant@student.42lisboa.com    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/05/06 14:53:50 by migusant          #+#    #+#              #
#    Updated: 2025/05/06 17:11:21 by migusant         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#!/bin/bash

# This script sets up and verifies the mail system (mailutils), Postfix, and Rsyslog for logging mail events.
# It ensures that mail logs are written to /var/log/mail.log and tests the setup.

echo "Starting setup for mail system, Postfix, and Rsyslog..."

# Step 1: Check and install mailutils
echo "Checking if mailutils is installed..."
if ! dpkg -l | grep -q mailutils; then
  echo "mailutils is not installed. Installing mailutils..."
  sudo apt update
  sudo apt install mailutils -y
else
  echo "mailutils is already installed."
fi

# Step 2: Check and install Postfix
echo "Checking if Postfix is installed..."
if ! dpkg -l | grep -q postfix; then
  echo "Postfix is not installed. Installing Postfix..."
  sudo apt update
  sudo apt install postfix -y
  echo "Configuring Postfix..."
  # During installation, select "Local only" unless external email sending is required.
else
  echo "Postfix is already installed."
fi

# Ensure Postfix is running and enabled
echo "Starting and enabling Postfix service..."
sudo systemctl start postfix
sudo systemctl enable postfix

echo "Checking Postfix status..."
sudo systemctl status postfix

# Step 3: Check and install Rsyslog
echo "Checking if Rsyslog is installed..."
if ! dpkg -l | grep -q rsyslog; then
  echo "Rsyslog is not installed. Installing Rsyslog..."
  sudo apt update
  sudo apt install rsyslog -y
else
  echo "Rsyslog is already installed."
fi

# Ensure Rsyslog is running and enabled
echo "Starting and enabling Rsyslog service..."
sudo systemctl start rsyslog
sudo systemctl enable rsyslog

echo "Checking Rsyslog status..."
timeout 1 sudo systemctl status rsyslog

# Step 4: Configure Rsyslog for mail logs
echo "Configuring Rsyslog for mail logs..."
MAIL_CONF="/etc/rsyslog.d/mail.conf"
if [ ! -f "$MAIL_CONF" ]; then
  echo "Creating $MAIL_CONF..."
  sudo bash -c "echo 'mail.*                        -/var/log/mail.log' > $MAIL_CONF"
else
  echo "$MAIL_CONF already exists. Skipping creation."
fi

# Restart Rsyslog to apply the configuration
echo "Restarting Rsyslog to apply changes..."
sudo systemctl restart rsyslog

# Step 5: Verify /var/log/mail.log existence
MAIL_LOG="/var/log/mail.log"
if [ ! -f "$MAIL_LOG" ]; then
  echo "$MAIL_LOG does not exist. Creating it manually..."
  sudo touch "$MAIL_LOG"
  sudo chmod 640 "$MAIL_LOG"
  sudo chown syslog:adm "$MAIL_LOG"
else
  echo "$MAIL_LOG already exists."
fi

# Step 6: Test the mail system
echo "Sending a test email..."
echo "Test mail body" | mail -s "Test Email" root

# Step 7: Check mail log entries
echo "Checking /var/log/mail.log for entries..."
if sudo cat "$MAIL_LOG" | grep -q "Test Email"; then
  echo "Mail log contains entries for the test email."
else
  echo "No entries found in $MAIL_LOG. Something might be misconfigured."
fi

echo "Setup and verification complete."