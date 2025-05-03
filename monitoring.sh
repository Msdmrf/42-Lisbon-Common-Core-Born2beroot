#!/bin/bash

# Architecture
arch_info=$(uname -a)
printf "#Architecture: %s\n" "$arch_info"

# CPU Physical Sockets
cpu_sockets=$(lscpu | grep -E '^Socket\(s\):' | awk '{print $2}')
printf "#CPU physical: %s\n" "$cpu_sockets"

# Virtual CPUs
vcpu_count=$(nproc)
printf "#vCPU: %s\n" "$vcpu_count"

# Memory Usage
mem_info=$(free -m | grep '^Mem:' | awk '{printf "%d/%dMB (%.2f%%)", $3, $2, $3/$2 * 100.0}')
printf "#Memory Usage: %s\n" "$mem_info"

# Disk Usage
disk_used_gb=$(df -BG --total | grep '^total' | awk '{print $3}' | sed 's/G//')
disk_total_gb=$(df -BG --total | grep '^total' | awk '{print $2}' | sed 's/G//')
disk_perc=$(df --total | grep '^total' | awk '{print $5}')
printf "#Disk Usage: %s/%sGb (%s)\n" "$disk_used_gb" "$disk_total_gb" "$disk_perc"

# CPU Load
cpu_load=$(mpstat | grep 'all' | awk '{print $4 + $6}')
printf "#CPU load: %.1f%%\n" "$cpu_load"

# Last Boot Time
last_boot=$(who -b | awk '{print $3 " " $4}')
printf "#Last boot: %s\n" "$last_boot"

# LVM Use
if grep -q '/dev/mapper' /etc/fstab; then
    lvm_status="yes"
else
    lvm_status="no"
fi
printf "#LVM use: %s\n" "$lvm_status"

# TCP Connections
tcp_conns=$(ss -t -n state established | wc -l)
if [ "$tcp_conns" -gt 0 ]; then
    tcp_conns=$((tcp_conns - 1))
else
    tcp_conns=0
fi
printf "#Connections TCP: %d ESTABLISHED\n" "$tcp_conns"

# User Logins
user_logins=$(w -h | wc -l)
printf "#User log: %d\n" "$user_logins"

# Network IP and MAC Address
primary_interface=$(ip route | grep 'default' | awk '{print $5}')
ip_addr=$(ip -o -4 addr show "$primary_interface" 2>/dev/null | awk '{print $4}' | cut -d'/' -f1)
mac_addr=$(ip link show "$primary_interface" 2>/dev/null | grep 'ether' | awk '{print $2}')
if [ -z "$ip_addr" ]; then
    ip_addr="Not found"
fi
if [ -z "$mac_addr" ]; then
    mac_addr="N/A"
fi
printf "#Network: IP %s (%s)\n" "$ip_addr" "$mac_addr"

# Sudo Command Count
if [ "$EUID" -ne 0 ]; then
    printf "#Sudo: must be root or have sudo privileges\n"
else
    sudo_log_file="/var/log/sudo/seq"
    sudo_count=0
    if [ -f "$sudo_log_file" ] && [ -r "$sudo_log_file" ]; then
        sudo_count=$(echo "obase=10; ibase=36; $(cat "$sudo_log_file")" | bc 2>/dev/null || echo "-1")
    fi
    printf "#Sudo: %d cmd\n" "$sudo_count"
fi
