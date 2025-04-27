#!/bin/bash

# Architecture
arch_info=$(uname -a)
printf "#Architecture: %s\n" "$arch_info"

# CPU Physical Sockets
# Using lscpu to find the number of physical sockets
cpu_sockets=$(lscpu | grep -E '^Socket\(s\):' | awk '{print $2}')
printf "#CPU physical: %s\n" "$cpu_sockets"

# Virtual CPUs
# Using nproc to get the number of processing units available
vcpu_count=$(nproc)
printf "#vCPU: %s\n" "$vcpu_count"

# Memory Usage
# Using free -m and awk to extract used and total memory in MB and calculate percentage
mem_info=$(free -m | awk '/^Mem:/ {printf "%d/%dMB (%.2f%%)", $3, $2, $3/$2 * 100.0}')
printf "#Memory Usage: %s\n" "$mem_info"

# Disk Usage
# Using df --total to get combined disk usage, converting to GB for used/total, keeping percentage
disk_used_gb=$(df -BG --total | awk 'END{print $3}' | sed 's/G//')
disk_total_gb=$(df -BG --total | awk 'END{print $2}' | sed 's/G//')
disk_perc=$(df -h --total | awk 'END{print $5}')
printf "#Disk Usage: %s/%sGb (%s)\n" "$disk_used_gb" "$disk_total_gb" "$disk_perc"

# CPU Load
# Using mpstat to get CPU utilization (user + system), requires sysstat package
# Summing the %usr and %sys columns from the 'all' average line
cpu_load=$(mpstat | awk '/all/ {print $4 + $6}')
printf "#CPU load: %.2f%%\n" "$cpu_load"

# Last Boot Time
# Using who -b to find the last boot time
last_boot=$(who -b | awk '{print $3 " " $4}')
printf "#Last boot: %s\n" "$last_boot"

# LVM Use
# Checking /etc/fstab for entries related to /dev/mapper (common for LVM)
if grep -q '/dev/mapper' /etc/fstab; then
    lvm_status="yes"
else
    lvm_status="no"
fi
printf "#LVM use: %s\n" "$lvm_status"

# TCP Connections
# Using ss to count established TCP connections (excluding header line)
tcp_conns=$(ss -t -n state established | wc -l)
# Subtract 1 for the header line, ensure it's not negative if count is 0
if [ "$tcp_conns" -gt 0 ]; then
    tcp_conns=$((tcp_conns - 1))
else
    tcp_conns=0
fi
printf "#Connections TCP: %d ESTABLISHED\n" "$tcp_conns"

# User Logins
# Using 'w' command, count lines and subtract 2 for header lines
user_logins=$(w -h | wc -l) # w -h skips header, simpler count
printf "#User log: %d\n" "$user_logins"

# Network IP and MAC Address
# Finding the primary IP (non-loopback) and its corresponding MAC address
# This assumes the primary interface name starts with 'enp' as per the original example
# A more robust method might be needed for different naming schemes
ip_addr=$(ip address show | grep "inet " | grep -v "127.0.0.1" | grep "enp" | head -n 1 | awk '{print $2}' | cut -d'/' -f1)
interface=$(ip address show | grep "inet " | grep -v "127.0.0.1" | grep "enp" | head -n 1 | awk '{print $NF}')
mac_addr=$(ip link show "$interface" | awk '/ether/ {print $2}')
# Fallback if no 'enp' interface found with IP
if [ -z "$ip_addr" ]; then
    ip_addr="Not found"
    mac_addr="N/A"
fi
printf "#Network: IP %s (%s)\n" "$ip_addr" "$mac_addr"

# Sudo Command Count
# Reading the sequence number from /var/log/sudo/seq and converting from base36
# Requires sudoers configured with 'Defaults log_input, log_output, iolog_dir=/var/log/sudo'
# Requires the 'bc' package
sudo_log_file="/var/log/sudo/seq"
if [ -f "$sudo_log_file" ] && [ -r "$sudo_log_file" ]; then
    # Convert base36 sequence number (often lowercase) to decimal
    sudo_count=$(echo "obase=10; ibase=36; $(tr '[:upper:]' '[:lower:]' < "$sudo_log_file")" | bc)
else
    sudo_count=0
fi
printf "#Sudo: %d cmd\n" "$sudo_count"
