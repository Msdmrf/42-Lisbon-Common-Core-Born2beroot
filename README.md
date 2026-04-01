*This project has been created as part of the 42 curriculum by migusant.*

# Born2beroot

A system administration project focused on **virtualization, secure server configuration, and automation** using VirtualBox. This project demonstrates encrypted disk partitioning with LVM, SSH hardening, firewall management, sudo policy enforcement, and system monitoring via Bash scripting on Debian.

## Description

The Born2beroot project involves setting up a secure Debian virtual machine from scratch with strict configuration requirements. The server runs without a graphical interface, uses encrypted partitions with LVM, enforces a strong password policy, restricts SSH access, configures a firewall, and implements comprehensive sudo security rules. A monitoring script broadcasts system metrics to all logged-in users every 10 minutes via cron.

### Key Features

- **LUKS-encrypted partitions** with Logical Volume Management (LVM) for flexible, secure disk organization
- **SSH hardening** with custom port (4242), root login disabled, and key-based restrictions
- **UFW firewall** configured to allow only essential ports (SSH on 4242)
- **Strict sudo policy** with logging, TTY requirement, limited password attempts, and custom secure PATH
- **Strong password policy** enforced via `libpam-pwquality` (minimum 10 characters, uppercase, lowercase, digit, max 3 consecutive identical characters, username rejection)
- **Password aging** with 30-day expiration, 2-day minimum change interval, and 7-day warning
- **System monitoring script** broadcasting architecture, CPU, memory, disk, network, and sudo usage via `wall`
- **Automated cron job** running the monitoring script every 10 minutes
- **WordPress stack (bonus)** with Lighttpd, MariaDB, and PHP-FPM
- **Docker installation (bonus)** as free-choice service for containerized application deployment
- **Serveo SSH tunnel service** for remote access via systemd service unit
- **Mail logging setup** with Postfix and Rsyslog for sudo `mail_badpass` notifications

### Project Structure

```
├── monitoring.sh              # System monitoring script (architecture, CPU, memory, disk, network, sudo)
├── mail_logging.sh            # Setup script for mailutils, Postfix, and Rsyslog mail logging
├── serveo-tunnel.service.sh   # Systemd service setup for Serveo SSH tunnel (remote access)
├── Evaluation.md              # Comprehensive evaluation guide with commands and expected outputs
├── Debian.txt                 # Debian ISO download instructions
├── Docker.txt                 # Docker installation guide for Debian VM
├── Apache2.txt                # Apache2 port configuration notes
├── Wireguard.txt              # WireGuard VPN configuration reference
├── signature.txt              # VM disk image SHA1 signature
├── en.subject.pdf             # Original 42 project subject
└── LICENSE
```

## Instructions

### VM Setup

The virtual machine uses **VirtualBox** with a Debian netinstall ISO. The VM runs in headless mode (no graphical environment) with `multi-user.target` as the default systemd target.

**Disk Partitioning (Bonus Layout):**

| Partition | Mount Point | Purpose |
|-----------|-------------|---------|
| `sda1` | `/boot` | Bootloader (GRUB) and kernel files (unencrypted) |
| `sda5_crypt` | — | LUKS-encrypted container with LVM |
| `root` | `/` | Core OS files and binaries |
| `var` | `/var` | Variable data (logs, caches) |
| `swap_1` | `[SWAP]` | Virtual memory |
| `tmp` | `/tmp` | Temporary files |
| `home` | `/home` | User home directories |
| `srv` | `/srv` | Server application data |
| `var--log` | `/var/log` | System log files |

### Connecting to the VM

```bash
# SSH into the VM (port-forwarded from host 2222 to guest 4242)
ssh migusant@localhost -p 2222
```

### Monitoring Script

The `monitoring.sh` script is placed in `/root/` (restricted to root access) and executed via a cron job in `/etc/cron.d/monitoring`:

```bash
*/10 * * * * root bash /root/monitoring.sh | wall
```

**Monitored metrics:**
- System architecture (`uname -a`)
- Physical CPU sockets and virtual CPU count
- Memory and disk usage with percentages
- CPU load (`mpstat`)
- Last boot time
- LVM status
- Active TCP connections
- Logged-in user count
- Network IP and MAC address
- Total sudo commands executed (from `/var/log/sudo/seq`)

### Bonus Services

#### WordPress (Lighttpd + MariaDB + PHP-FPM)

```bash
# Verify services
sudo systemctl status lighttpd
sudo systemctl status mariadb
sudo systemctl status php*-fpm

# Access WordPress
# Homepage: http://127.0.0.1:2904/
# Admin:    http://127.0.0.1:2904/wp-admin
```

#### Docker

```bash
# Verify Docker installation
docker run hello-world
```

## Technical Implementation

### Security Configuration

**SSH (`/etc/ssh/sshd_config`):**
- `Port 4242` — Non-default port to reduce automated scanning
- `PermitRootLogin no` — Prevents direct root SSH access

**UFW Firewall:**
- Only port `4242/tcp` allowed (SSH)
- All other inbound traffic denied by default

**Sudo Policy (`/etc/sudoers.d/`):**

| Rule | Purpose |
|------|---------|
| `env_reset` | Clears environment variables to a safe default set |
| `mail_badpass` | Sends email notification on failed sudo password attempts |
| `secure_path` | Restricts PATH to `/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin` |
| `requiretty` | Requires sudo to be run from a terminal (TTY) |
| `badpass_message` | Custom message for incorrect sudo passwords |
| `logfile="/var/log/sudo/sudo.log"` | Logs all sudo commands |
| `log_input`, `log_output` | Records input/output of sudo sessions |
| `iolog_dir=/var/log/sudo` | Directory for I/O session logs |
| `passwd_tries=3` | Limits incorrect password attempts to 3 |

**Password Policy:**

| Setting | Value | Configuration File |
|---------|-------|--------------------|
| `PASS_MAX_DAYS` | 30 | `/etc/login.defs` |
| `PASS_MIN_DAYS` | 2 | `/etc/login.defs` |
| `PASS_WARN_AGE` | 7 | `/etc/login.defs` |
| `minlen` | 10 | `/etc/pam.d/common-password` |
| `dcredit` | -1 (at least 1 digit) | `/etc/pam.d/common-password` |
| `ucredit` | -1 (at least 1 uppercase) | `/etc/pam.d/common-password` |
| `lcredit` | -1 (at least 1 lowercase) | `/etc/pam.d/common-password` |
| `maxrepeat` | 3 | `/etc/pam.d/common-password` |
| `difok` | 7 | `/etc/pam.d/common-password` |
| `reject_username` | enabled | `/etc/pam.d/common-password` |
| `enforce_for_root` | enabled | `/etc/pam.d/common-password` |

### Monitoring Script Implementation

The script uses standard Linux utilities to gather system information:
- `uname -a` — Full system architecture string
- `lscpu` — Physical CPU socket count
- `nproc` — Virtual CPU count
- `free -m` — Memory usage in MB with percentage calculation
- `df -BG --total` — Disk usage in GB across all mounted filesystems
- `mpstat` — CPU load percentage (user + system)
- `who -b` — Last boot timestamp
- `ss -t -n state established` — Active TCP connection count
- `w -h` — Logged-in user count
- `ip route` / `ip addr` / `ip link` — Network interface IP and MAC address
- `/var/log/sudo/seq` — Sudo command count (base-36 to decimal conversion via `bc`)

### WordPress Stack (Bonus)

- **Lighttpd** serves static content and proxies PHP requests via `mod_fastcgi`
- **MariaDB** stores WordPress data in a dedicated `wordpress` database with a restricted `wp_user` account
- **PHP-FPM** processes dynamic WordPress content as a FastCGI application

### Serveo SSH Tunnel

A systemd service (`serveo-tunnel.service`) maintains a persistent reverse SSH tunnel through `serveo.net`, forwarding port 4242 for remote SSH access. The service auto-restarts on failure and runs under the `migusant` user account.

## Resources

### Virtualization

- [VirtualBox Documentation](https://www.virtualbox.org/manual/) — VM creation and configuration
- [Debian Netinstall](https://www.debian.org/distrib/netinst) — Minimal Debian ISO download

### Disk Encryption & LVM

- `man cryptsetup(8)` — LUKS disk encryption management
- `man lvm(8)` — Logical Volume Manager overview
- `man pvcreate(8)`, `man vgcreate(8)`, `man lvcreate(8)` — LVM component creation
- [LUKS Documentation](https://gitlab.com/cryptsetup/cryptsetup/-/wikis/home) — Linux Unified Key Setup

### User & Password Management

- `man login.defs(5)` — Password aging configuration
- `man pam_pwquality(8)` — Password quality checking module
- `man adduser(8)` — User creation
- `man usermod(8)` — User modification and group assignment

### SSH

- `man sshd_config(5)` — SSH daemon configuration
- `man ssh(1)` — SSH client usage
- `man ufw(8)` — Uncomplicated Firewall management

### Sudo

- `man sudoers(5)` — Sudo policy configuration
- `man visudo(8)` — Safe sudoers file editing
- `man sudoreplay(8)` — Sudo session log replay

### System Monitoring

- `man cron(8)` — Cron daemon for scheduled tasks
- `man wall(1)` — Broadcast messages to all logged-in users
- `man mpstat(1)` — CPU usage statistics
- `man ss(8)` — Socket statistics
- `man lscpu(1)` — CPU architecture information

### Bonus Services

- [Lighttpd Documentation](https://www.lighttpd.net/) — Lightweight web server
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/) — Database server
- [WordPress Installation](https://developer.wordpress.org/advanced-administration/before-install/howto-install/) — CMS setup guide
- [Docker Documentation](https://docs.docker.com/) — Container platform

### Debugging Tools

- `man valgrind(1)` — Memory error detection
- [Valgrind Manual](https://valgrind.org/docs/manual/manual.html) — Comprehensive debugging guide

### AI Usage

AI tools (GitHub Copilot, ChatGPT) were used as a **thinking partner and debugging assistant** to discuss problems and approaches, but all final configurations, architecture decisions, and troubleshooting were performed by the student after understanding the underlying concepts.

**Documentation & Understanding:**
- Explaining Linux security concepts (AppArmor, LUKS encryption, LVM)
- Clarifying SSH hardening best practices and sshd_config options
- Understanding sudo policy rules and their security implications
- Discussing password policy modules (`pam_pwquality`) and configuration parameters
- Refining and structuring README.md documentation to accurately represent technical implementations

**Code Review:**
- Reviewing monitoring script for correctness and edge case handling
- Verifying cron job syntax and scheduling behavior
- Checking systemd service unit configuration for the Serveo tunnel

**Learning Resources:**
- Providing reference for UFW firewall rule management
- Clarifying differences between Debian and Rocky Linux package management and security modules
- Explaining LVM concepts (PVs, VGs, LVs) and their practical benefits

**Testing Assistance & Debugging:**
- Helping verify SSH configuration and port forwarding setup
- Debugging sudo logging and mail notification configuration
- Testing WordPress stack integration (Lighttpd + MariaDB + PHP-FPM)

## License

This project is part of the 42 Common Core curriculum. See [LICENSE](LICENSE) for details.
