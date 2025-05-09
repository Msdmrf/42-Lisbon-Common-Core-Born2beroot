
---

**Author:** migusant (<migusant@student.42lisboa.com>)  
**Created:** 2025/05/05 15:47:11  
**Updated:** 2025/05/09 16:11:52  

---

# Evaluation

The project involves creating and configuring a virtual machine following strict rules. 
The evaluated person will need to assist you during the defense. 
Make sure all the following points are respected.

---

## General Guidelines

**Note:** During the defense, as soon as you need help to verify a point, the evaluated person must assist you:

1. **Precaution:**  
   You may duplicate the original virtual machine to keep a copy.

2. **Check File Presence:**  
   Ensure that the `signature.txt` file is present at the root of the cloned repository.

3. **Verify Signature Match:**  
   Ensure that the signature contained in `signature.txt` matches that of the `.vdi` file of the virtual machine being evaluated.  
   - **Path:**  
     `/home/migusant/sgoinfre/Born2beroot/Born2beroot.vdi`
   - **Diff Command:**  
     ```bash
     diff <(sha1sum /home/migusant/sgoinfre/Born2beroot/Born2beroot.vdi | cut -d' ' -f1) <(cat signature.txt)
     ```
   - **Diff Output:**  
     - If the signatures match, the `diff` command will produce no output.  
     - If the signatures do not match, `diff` will show the lines that differ (i.e., the two different hashes).

4. **Launch Virtual Machine:**  
   Launch the cloned virtual machine to be evaluated.

**Note:** If something does not work as expected or the two signatures differ, the evaluation stops here.

---

# Project Overview

**Note:** The evaluated person must simply explain:

1. **Basic Functioning of their Virtual Machine:**  
   "My virtual machine runs using VirtualBox on my host computer. The hypervisor creates a simulated hardware environment by allocating resources like CPU cores, RAM, and disk space from the host machine. Inside this isolated environment, I have installed and configured the Debian operating system. It functions like a separate computer, but it's entirely contained within the hypervisor software on my host."

2. **Choice of Operating System:**  
   "I chose Debian primarily because it's the required operating system for the Born2beroot project at 42. Additionally, Debian is well-regarded for its stability, extensive software repositories managed by apt, strong security focus, and its widespread use in server environments. This makes it an excellent platform for learning Linux system administration fundamentals."

3. **Basic Differences Between Rocky and Debian:**  
   "The main differences lie in their origins and package management. Rocky Linux is derived from Red Hat Enterprise Linux (RHEL) source code, aiming for binary compatibility with RHEL. It uses the RPM package format and the dnf package manager. Debian is an independent, community-driven project and the base for many other distributions like Ubuntu. It uses the DEB package format and the apt family of package managers (apt, apt-get, aptitude). They also have different philosophies regarding software inclusion and release cycles."

4. **Benefits of Virtual Machines:**  
   "Virtual machines offer several key benefits:  
      - **Isolation:** They provide a sandboxed environment, separating the guest OS from the host.  
      - **Resource Consolidation:** Multiple VMs can run on a single physical machine, making efficient use of hardware resources.  
      - **Snapshots:** You can save the state of a VM at any point (a snapshot) and easily revert to it if something goes wrong.  
      - **Testing & Development:** VMs allow easy creation of specific, reproducible environments for development or testing software.  
      - **Portability:** VM images can often be moved and run on different physical computers."

5. **If the Chosen OS is Rocky:**
   - **SELinux:**  
     "SELinux (Security-Enhanced Linux) is a Linux kernel security module enforcing Mandatory Access Control (MAC) policies. It assigns security labels to processes and resources, limiting privilege escalation and enhancing security by enforcing fine-grained access control."
   - **DNF:**  
     "DNF (Dandified YUM) is the high-level package manager for Rocky Linux, used to install, update, and manage `.rpm` packages. It improves dependency resolution and performance compared to yum."

6. **If the Chosen OS is Debian:**  
   - **apt vs. aptitude:**  
     "Both are high-level package managers for Debian. `apt` is simpler and widely used, while `aptitude` offers advanced dependency resolution and an interactive UI."  
   - **APPArmor:**  
     "APPArmor is a Linux security module that confines programs to predefined access rules, improving system security by limiting the resources a program can access."

7. **Monitoring Script:**  
   "I have created a monitoring script (`monitoring.sh`) which is located at `/root/monitoring.sh`, since i don't want users to be able to change it, not even with `sudo`. Then, I left the cron job in a `monitoring` file within the `/etc/cron.d/` directory. This cron job executes this script at boot, and every 10 minutes. The output, containing system metrics, is broadcast to all logged-in user terminals using `wall`. Script and crontab content will be checked during the evaluation."

**Note:** If the explanations are not clear, the evaluation stops here.

---

# Simple Configuration

**Note:** As soon as you need help to verify a point, the evaluated person must be able to assist you:

## 1. Verify Machine Configuration

### 1.1 No Graphical Environment at Startup:
- **Requirements:** The machine must not start with a graphical environment. A password will be requested before any connection attempt. Log in with a non-root user.  
- **Password Rules:**  
  - At least 10 characters long.  
  - Must contain:
    - An uppercase letter.
    - A lowercase letter.
    - A number.  
  - Must not have more than 3 consecutive identical characters.  
  - Must not include the user's name.  
- **Check User Password:**  
  Example Password: `M1gusant42us3r`  
- **Password Policies Command:**  
  ```bash
  sudo chage -l migusant
  ```
  - **Expiration:** Password must expire every 30 days.  
  - **Minimum Days Before Modification:** 2 days.  
  - **Warning Message:** Shown 7 days before expiration.

### 1.2 Log in with Non-Root User:
- **Command:**  
  ```bash
  whoami
  ```
- **Expected Output:**  
  ```bash
  migusant
  ```

### 1.3 Default Target for System Boot:
- **Command:**  
  ```bash
  systemctl get-default
  ```
- **Expected Output:**  
  - `multi-user.target`: Indicates a command-line boot environment.  
  - `graphical.target`: Indicates a GUI login manager and desktop boot environment. If no GUI exists, it defaults to command-line.

### 1.4 Check for Graphical Environment:
- **Commands:**  
  ```bash
  dpkg -l | grep -E "xserver|gnome|kde|xfce|lxde"
  ls /usr/bin | grep -E "startx|Xorg"
  ```
- **Expected Output:**  
  - If results are returned, graphical packages are installed.

## 2. Validate Operating System and Services

### 2.1 Verify Operating System:
- **Command:**  
  ```bash
  cat /etc/os-release
  ```
- **Expected Output:**  
  - Output should clearly identify the OS as "Debian".

### 2.2 Verify UFW Service:
- **Command:**  
  ```bash
  systemctl status ufw
  ```
- **Expected Output:**  
  ```bash
  Active: active (running)
  ```

### 2.3 Verify SSH Service:
- **Command:**  
  ```bash
  systemctl status ssh
  ```
- **Expected Output:**  
  ```bash
  Active: active (running)
  ```
- **Check SSH Port:**  
  Ensure it is listening on the specified port (e.g., 4242) and not the default port 22.

**Note:** If something does not work as expected or is not clearly explained, the evaluation stops here.

---

# User

**Note:** As soon as you need help to verify a point, the evaluated person must be able to assist you:

## 1. Verify User and Group Membership

### 1.1 Verify User Existence and Group Membership:
- **Requirement:** A user with the login name of the evaluated person must be present on the virtual machine and belong to the `sudo` and `user42` groups.  
- **Command:**  
  ```bash
  id migusant
  # OR
  groups migusant
  ```
- **Expected Output:**  
  Look for `migusant`'s UID/GID information and verify that both `sudo` and `user42` are listed in the `groups=` section.

## 2. Verify Password Policy Implementation

### 2.1 Create a New User and Verify Password Policy:
- **Create User Command:**  
  ```bash
  sudo adduser testuser
  ```
- **Assign Password Command (if not prompted):**  
  ```bash
  sudo passwd testuser
  ```
- **Password Policy Check:**  
  - The system should:
    - Reject passwords with less than 10 characters.
    - Reject passwords without at least one uppercase letter, one lowercase letter, and one digit.
    - Reject passwords that include the username.
    - Accept passwords that meet all criteria.

### 2.2 Explanation of Password Policy Implementation:
- **Password Aging/Expiration:**  
  - Edited `/etc/login.defs` to set:  
    - `PASS_MAX_DAYS` (e.g., 30 or 90) to force password changes.  
    - `PASS_MIN_DAYS` (e.g., 2) to prevent immediate changes.  
    - `PASS_WARN_AGE` (e.g., 7) to warn users before expiration.

- **Password Strength/Complexity:**  
  - Installed `libpam-pwquality` package (if not present).  
  - Edited `/etc/pam.d/common-password` to configure `pam_pwquality.so` with:  
    - `retry=3` (limit password attempts).  
    - `minlen=10` (minimum length).  
    - `dcredit=-1` (at least one digit).  
    - `ucredit=-1` (at least one uppercase).  
    - `lcredit=-1` (at least one lowercase).  
    - `ocredit=-1` (at least one special character).  
    - `difok=7` (must differ from old password by 7 characters).  
    - `reject_username` (prevent using username in password).

## 3. Create and Assign a New Group

### 3.1 Create a New Group and Assign the User:
- **Create Group Command:**  
  ```bash
  sudo addgroup evaluating
  ```
- **Add User to Group Command:**  
  ```bash
  sudo usermod -aG evaluating testuser
  ```
- **Verify Group Membership Command:**  
  ```bash
  id testuser
  # OR
  groups testuser
  ```
- **Expected Output:**  
  Look for `testuser`'s UID/GID information and verify that `evaluating` is listed in the `groups=` section.

## 4. Explain the Purpose of the Password Policy

- **Purpose:**  
  The primary purpose of the password policy is to enhance system security by making user accounts harder to compromise through brute-forcing or password reuse attacks.

- **Advantages:**  
  - **Increased Security:** Complex passwords are harder to guess or crack.  
  - **Reduced Risk:** Prevents weak, guessable passwords and password reuse.  
  - **Compliance:** Meets security best practices and potential compliance requirements.  
  - **Accountability:** Enforces a minimum security standard across users.

- **Disadvantages:**  
  - **User Inconvenience:** Difficult to remember complex passwords and frequent changes.  
  - **Insecure Practices:** Users might write down passwords or use predictable patterns.  
  - **Potential Lockouts:** Increased support requests for password resets.  
  - **Complexity ≠ Strength:** Users may create weak but technically compliant passwords (e.g., `Password123!`).

**Note:** If something does not work as expected or is not clearly explained, the evaluation stops here.

---

# Hostname and Partitions

**Note:** As soon as you need help to verify a point, the evaluated person must be able to assist you:

## 1. Verify Hostname

### 1.1 Check Current Hostname:
- **Command:**  
  ```bash
  hostname
  ```
- **Expected Output:**  
  ```bash
  migusant42
  ```

### 1.2 Change Hostname and Restart:
- **Wrong Command (Non-Persistent):**
  ```bash
  hostname testevaluator
  ```
  - This changes the hostname only for the current session but does not persist across reboots.

- **Right Process for Persistent Change:**  
  1. Edit `/etc/hostname`:  
     ```bash
     sudo nano /etc/hostname
     ```
     Change the content to the new hostname (e.g., `testevaluator`).

  2. Edit `/etc/hosts`:  
     ```bash
     sudo nano /etc/hosts
     ```
     Replace any occurrences of the old hostname with the new one (e.g., `127.0.1.1 testevaluator`).

  3. Restart the machine:  
     ```bash
     sudo reboot
     ```

- **Verify Change:**  
  ```bash
  hostname
  ```

### 1.3 Restore Original Hostname:
- **Process to Restore:**  
  1. Edit `/etc/hostname`:  
     ```bash
     sudo nano /etc/hostname
     ```
     Change the content back to the original hostname (e.g., `migusant42`).

  2. Edit `/etc/hosts`:  
     ```bash
     sudo nano /etc/hosts
     ```
     Replace any occurrences of the new hostname with the original one (e.g., `127.0.1.1 migusant42`).

  3. Restart the machine:  
     ```bash
     sudo reboot
     ```

- **Verify Restoration:**  
  ```bash
  hostname
  ```

## 2. Display Partitions

### 2.1 Check Partitions:
- **Command:**  
  ```bash
  lsblk
  ```
- **Expected Output:**  
  - At least 2 encrypted partitions using LVM.  
  - Check the number of lines below `sdaX_crypt`.  
  - If the evaluatee completed the BONUS part, refer to the subject for the expected partitioning example.

## 3. Explanation of LVM (Logical Volume Management)

LVM is a system for managing disk storage that abstracts the physical layout of the disks. It provides flexibility and simplifies disk management.  
- **Components:**  
  - **Physical Volumes (PVs):** Actual physical drives or partitions (e.g., `/dev/sda2`).  
  - **Volume Groups (VGs):** Combine one or more PVs into a single storage pool.  
  - **Logical Volumes (LVs):** Virtual partitions created from VGs, which can be formatted and mounted like regular partitions.  

- **Example:**  
  - Create a volume group named `vg-root`.  
  - Create logical volumes like `lv-root` (for `/`) and `lv-swap` (for swap space).

- **Benefits:**  
  - **Flexibility:** Resize logical volumes dynamically without unmounting them (e.g., extend `/home` if out of space).  
  - **Snapshots:** Create snapshots for backups or testing.  
  - **Disk Management:** Add more physical volumes to a volume group to increase storage without downtime.  
  - **Simplified Partitioning:** Create partitions on-the-fly without worrying about fixed sizes.

**Note:** If something does not work as expected or is not clearly explained, the evaluation stops here.

---

# SUDO

**Note:** As soon as you need help to verify a point, the evaluated person must be able to assist you:

## 1. Verify SUDO Installation
- **Command:**  
  ```bash
  sudo --version
  ```
- **Expected Output:**  
  `Sudo version 1.9.x`

## 2. Add User to SUDO Group
- **Add to Group Command:**  
  ```bash
  sudo usermod -aG sudo testuser
  ```
- **Verify Group Membership Command:**  
  ```bash
  id testuser
  # OR
  groups testuser
  ```
- **Expected Output:**  
  `sudo` must be listed in the `groups=` section of the output.

## 3. Explain Purpose and Example Usage of SUDO
- **Purpose:**  
  `sudo` allows users to execute commands with elevated privileges, acting as an alternative to logging in as root. It enhances security by restricting access, logging commands, and requiring authentication.

- **Example Operations:**  
  - Update and upgrade the system:  
    ```bash
    sudo apt update && sudo apt upgrade
    ```
  - Edit a system file:  
    ```bash
    sudo nano /etc/hostname
    ```
  - Restart a system service:  
    ```bash
    sudo systemctl restart ssh
    ```

## 4. Demonstrate SUDO Rules in "sudoers" File

### 4.1 Rule: `env_reset`
- **Purpose:** Clears environment variables except for a safe default set.  
- **Test Commands:**  
  ```bash
  env
  sudo env
  ```
- **Expected Output:**  
  Most environment variables (e.g., PATH) are reset to a secure default when running `sudo env`.

### 4.2 Rule: `mail_badpass`
- **Purpose:** Sends an email to the system administrator if a user enters an incorrect sudo password.  
- **Setup Commands:**  
  1. Install `mailutils`, `postfix`, and `rsyslog` if not already installed:
     ```bash
     sudo apt update
     sudo apt install mailutils postfix rsyslog -y
     ```
  2. Configure `postfix` and `rsyslog` to handle mail logs:
     - Edit `/etc/rsyslog.d/mail.conf` to include:
       ```bash
       mail.* -/var/log/mail.log
       ```
     - Restart `rsyslog`:
       ```bash
       sudo systemctl restart rsyslog
       ```
  3. Test the setup:
     ```bash
     echo "Test mail body" | mail -s "Test Email" root
     sudo cat /var/log/mail.log
     ```
- **Test Commands for `mail_badpass`:**
  1. Fail a sudo password attempt:
     ```bash
     sudo ls
     ```
  2. Check for mail:
     ```bash
     mail
     cat /var/mail/migusant
     ```

### 4.3 Rule: `secure_path`
- **Purpose:** Sets a secure PATH for sudo commands.  
- **Test Commands:**  
  ```bash
  su -
  echo $PATH
  ```
- **Expected Output:**  
  `/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin`

### 4.4 Rule: `requiretty`
- **Purpose:** Requires sudo to be run from a terminal (TTY).  
- **Test Commands:**  
  ```bash
  ssh migusant@localhost -p 2222 "sudo ls"
  ```
- **Expected Output:**  
  `sudo: sorry, you must have a tty to run sudo`

### 4.5 Rule: `badpass_message="WRONG PASSWORD"`
- **Purpose:** Changes the message displayed for incorrect sudo passwords.  
- **Test Command:**  
  ```bash
  sudo ls
  ```
- **Expected Output:**  
  `WRONG PASSWORD`

### 4.6 Rule: `logfile="/var/log/sudo/sudo.log"`
- **Purpose:** Logs all sudo commands to the specified file.  
- **Test Commands:**  
  ```bash
  sudo ls /root
  sudo tail -n 5 /var/log/sudo/sudo.log
  ```
- **Expected Output:**  
  ```bash
  COMMAND=/usr/bin/ls /root
  COMMAND=/usr/bin/tail -n 5 /var/log/sudo/sudo.log
  ```

### 4.7 Rules: `log_input` and `log_output`
- **Purpose:** Logs both input and output of sudo commands.  
- **Test Commands:**  
  ```bash
  sudo ls /root
  ```
  - Check session ID in `TSID=XX`.  
  - Verify logs:
    ```bash
    su -
    ls /var/log/sudo/00/00/XX
    sudo sudoreplay /var/log/sudo/00/00/XX
    ```

### 4.8 Rule: `iolog_dir=/var/log/sudo`
- **Purpose:** Specifies the directory for input/output logs.  
- **Test Commands:**  
  ```bash
  ls -ld /var/log/sudo
  cat /var/log/sudo/sudo.log
  ```

### 4.9 Rule: `passwd_tries=3`
- **Purpose:** Limits incorrect sudo password attempts to 3.  
- **Test Command:**  
  ```bash
  sudo ls
  ```
- **Expected Output:**  
  `sudo: 3 incorrect password attempts`

**Note:** If something does not work as expected or is not clearly explained, the evaluation stops here.

---

# UFW / Firewalld

**Note:** As soon as you need help to verify a point, the evaluated person must be able to assist you:

## 1. Verify Installation and Status

### 1.1 Check UFW (or Firewalld) Status:
- **Command:**
  ```bash
  systemctl status ufw
  ```
- **Expected Output:**  
  ```bash
  Active: active (running)
  ```

## 2. Explanation of UFW (or Firewalld)

- **Explanation:**  
  `"UFW (Uncomplicated Firewall) is a user-friendly frontend for managing iptables (the underlying Linux firewall). It simplifies the process of managing firewall rules and is commonly used on Ubuntu/Debian-based systems. Both UFW and Firewalld help secure servers by controlling inbound and outbound traffic. They allow only specific, trusted connections (e.g., SSH, HTTP/HTTPS) while blocking potentially malicious or unnecessary traffic. A properly configured firewall reduces the attack surface of a server and prevents unauthorized access."`

## 3. List Active Rules

### 3.1 Check Active Rules:
- **Command:**
  ```bash
  sudo ufw status
  ```
- **Expected Output:**  
  Look for a rule with the following syntax:  
  ```bash
  4242                       ALLOW       Anywhere
  ```

## 4. Add and Verify New Rule for Port 8080

### 4.1 Add Rule for Port 8080:
- **Command:**
  ```bash
  sudo ufw allow 8080
  sudo ufw status
  ```
- **Expected Output:**  
  Look for two new rules:  
  ```bash
  8080                       ALLOW       Anywhere
  8080 (v6)                  ALLOW       Anywhere (v6)
  ```

## 5. Delete the New Rule for Port 8080

### 5.1 Delete Rule:
- **Commands:**
  1. Check the index of the first `8080` rule:
     ```bash
     sudo ufw status numbered
     ```
  2. Delete the rule by its index (e.g., if it's index `3`):
     ```bash
     sudo ufw delete 3
     ```
     Confirm with `y`.  
  3. Repeat for the rule with index `5`:
     ```bash
     sudo ufw delete 5
     ```
     Confirm with `y`.

- **Verify Deletion:**
  ```bash
  sudo ufw status
  ```
- **Expected Output:**  
  The output should match that of **Section 3** (without the `8080` rules).

**Note:** If something does not work as expected or is not clearly explained, the evaluation stops here.

---

# SSH

**Note:** As soon as you need help to verify a point, the evaluated person must be able to assist you:

## 1. Verify SSH Installation and Status

### 1.1 Verify SSH Client and Service:
- **Commands:**
  ```bash
  ssh -V
  systemctl status ssh
  ```
- **Expected Output:**
  - `ssh -V`: Displays the SSH client version.
  - `systemctl status ssh`:  
    ```bash
    Active: active (running)
    ```

## 2. Explanation of SSH

- **Explanation:**  
  `"SSH (Secure Shell) is a protocol that allows secure remote access to a server or computer over an encrypted connection. It enables users to execute commands and manage systems remotely while ensuring that data is protected from eavesdropping and tampering. It's important to use because it provides a secure way to manage servers, especially for administrators who need to remotely troubleshoot, configure, or monitor systems. It uses encryption to protect sensitive information, such as usernames, passwords, and commands."`

## 3. Verify SSH Port Configuration

### 3.1 Verify SSH Port:
- **Command to Check Configuration File:**
  ```bash
  sudo nano /etc/ssh/sshd_config
  ```
- **Expected Configuration:**  
  Only `Port 4242` should be listed or uncommented.

- **Command to Confirm Listening Port:**
  ```bash
  sudo ss -tuln | grep 4242
  ```
- **Expected Output:**
  ```bash
  tcp   LISTEN 0      128          0.0.0.0:4242      0.0.0.0:*     # IPv4
  tcp   LISTEN 0      128             [::]:4242         [::]:*     # IPv6
  ```

## 4. Test SSH Connection with New User

### 4.1 Connect via SSH:
- **Command:**
  ```bash
  ssh testuser@localhost -p 2222
  ```
- **Expected Result:**  
  Successful login after entering the password for `testuser`.

## 5. Verify Root User Restriction

### 5.1 Test Root Login:
- **Command:**
  ```bash
  ssh root@localhost -p 2222
  ```
- **Expected Result:**  
  ```bash
  Permission denied, please try again.
  ```
  - This is due to the line `PermitRootLogin no` in `/etc/ssh/sshd_config`.

**Note:** If something does not work as expected or is not clearly explained, the evaluation stops here.

---

# Script Monitoring

**Note:** As soon as you need help to verify a point, the evaluated person must be able to assist you:

## 1. Display Script Location and Reasoning

### 1.1 Location:
- **Script Location:** `/root/monitoring.sh`
- **Reasoning:**  
  `"I placed my monitoring.sh script in the /root directory to ensure that only the root user can access or modify it. By default, /root is restricted to root, adding an extra layer of security. Instead of placing the script in /etc/cron.d, I created a simple monitoring file in that directory containing only the cron job entry:  
  ```bash
  */10 * * * * root bash /root/monitoring.sh | wall
  ```
  This setup ensures the script runs securely every 10 minutes as root while keeping the actual script inaccessible to other users."

## 2. Display and Explain Script Code

### 2.1 Display Script Code:
- **Command to Display Code:**
  ```bash
  cat /root/monitoring.sh
  ```

### 2.2 Explanation:
- The script's purpose, functionality, and key commands used should be explained in detail by the evaluated person.

## 3. Explanation of Cron

- **Explanation:**  
  `"Cron is a time-based job scheduler in Unix-like operating systems. It allows users to schedule scripts or commands to execute automatically at specified intervals (e.g., every 10 minutes, every day). Jobs are defined in a file called a crontab. Each job in the crontab specifies the minute, hour, day of the month, month, day of the week, and the command or script to execute."`

## 4. Configure Script to Run Every 10 Minutes

### 4.1 Configuration:
- **Location:** `/etc/cron.d/monitoring`
- **Cron Job Entry:**
  ```bash
  */10 * * * * root bash /root/monitoring.sh | wall
  ```
- **Explanation:**  
  `"The cron job in /etc/cron.d ensures the script runs every 10 minutes as the root user. The wall command broadcasts the output to all logged-in users."`

## 5. Change Cron Job to Run Every Minute

### 5.1 Steps:
1. Open the cron job file:
   ```bash
   nano /etc/cron.d/monitoring
   ```
2. Change the entry:
   ```bash
   * * * * * root bash /root/monitoring.sh | wall
   ```
3. Save and exit:
   - Save: `CTRL+O`
   - Exit: `CTRL+X`
4. Wait 1 minute to verify that the script runs every minute.

## 6. Modify Script to Include a Timestamp

### 6.1 Add Timestamp:
- **Commands to Modify Script:**
  ```bash
  current_time=$(date '+%Y-%m-%d %H:%M:%S')
  printf "#Current Time: %s\n\n" "$current_time"
  ```
- **Expected Output:**  
  A line with the current timestamp:
  ```bash
  #Current Time: YEAR-MONTH-DAY HOUR:MINUTE:SECOND
  ```

## 7. Disable Script Execution at Reboot

### 7.1 Steps:
1. Switch to root:
   ```bash
   su -
   ```
2. Verify script permissions:
   ```bash
   ls -l /root/monitoring.sh
   ```
3. Open the cron job file:
   ```bash
   nano /etc/cron.d/monitoring
   ```
4. Comment out the reboot entry:
   ```bash
   #@reboot root sleep 15 && bash /root/monitoring.sh | wall
   ```
5. Save and exit:
   - Save: `CTRL+O`
   - Exit: `CTRL+X`
6. Reboot the machine:
   ```bash
   reboot
   ```
7. Verify script permissions again:
   ```bash
   ls -l /root/monitoring.sh
   ```

**Note:** If any of the above points are not correct or clearly explained, the evaluation stops here.

---

# Bonus

**Note:** Bonuses will only be examined if the mandatory part is excellent. This means that the mandatory part must have been completed from start to finish, with perfect error management even in cases of unexpected use. If all mandatory points have not been awarded during this defense, no bonus points will be counted.

## 1. Disk Partitions (2 Points)

### **Partition Details**
- `/boot (sda1)`: Contains the bootloader (e.g., GRUB) and kernel files. Ensures accessibility even if the rest of the disk is encrypted.
- `sda2`: Placeholder or reserved partition.
- `sda5`: Main partition containing a LUKS-encrypted volume (`sda5_crypt`).
- `sda5_crypt`: Encrypted partition with Logical Volume Management (LVM) for flexible sub-partitions.

### **Logical Volumes Inside `sda5_crypt`**
- `/ (Root)` (`migusant42--vg-root`): Core OS files and binaries.
- `/var` (`migusant42--vg-var`): Variable files (logs, cached data).
- `[SWAP]` (`migusant42--vg-swap_1`): Virtual memory.
- `/tmp` (`migusant42--vg-tmp`): Temporary files.
- `/home` (`migusant42--vg-home`): User-specific files.
- `/srv` (`migusant42--vg-srv`): Server-specific application data.
- `/var/log` (`migusant42--vg-var--log`): System logs.

### **Other Devices**
- `sr0`: External media (e.g., installation disks).

### **Benefits**
- **Security:** LUKS encryption ensures data protection.
- **Organization:** Isolated partitions prevent interference.
- **Performance:** LVM allows dynamic resizing.
- **Reliability:** Isolated directories ensure stability.

## 2. WordPress Setup (2 Points)

### **Lighttpd**
- **What is Lighttpd?**
  `"Lighttpd (lighty) is a lightweight, high-performance web server designed for speed, security, and minimal resource usage."`
- **Usage in Project:**
  - Hosts WordPress.
  - Processes PHP requests via `mod_fastcgi`.
  - Configured to serve `/var/www/html/wordpress`.
  - Enforces security by disabling directory listing and restricting access.

### **MariaDB**
- **What is MariaDB?**
  `"MariaDB is an open-source relational database system, widely used for managing structured data."`
- **Usage in Project:**
  - Backend for WordPress.
  - Stores posts, pages, and settings.
  - Secured with a dedicated database (`wordpress`) and user (`wp_user`).

### **PHP**
- **What is PHP?**
  `"PHP is a server-side scripting language, widely used for creating dynamic web applications."`
- **Usage in Project:**
  - Processes WordPress dynamic content.
  - Communicates with MariaDB.
  - Runs as a FastCGI app via PHP-FPM.

### **WordPress**
- **What is WordPress?**
  `"WordPress is an open-source CMS for creating and managing websites."`
- **Usage in Project:**
  - Core platform for the website.
  - Installed in `/var/www/html/wordpress`.
  - Uses MariaDB and PHP for storing and rendering content.

## 3. Test WordPress Website and Services

### **Lighttpd**
- **Verify Lighttpd Service:**
  ```bash
  sudo systemctl status lighttpd
  ```
  **Expected:** `active (running)`

- **Test Static Files:**
  ```bash
  echo "Lighttpd is working!" | sudo tee /var/www/html/test.html
  curl http://10.0.2.15/test.html
  ```
  **Expected:** `Lighttpd is working!`

- **Check Logs:**
  ```bash
  sudo tail -f /var/log/lighttpd/error.log
  ```
  **Expected:** No recurring errors.

- **Test PHP Integration:**
  ```bash
  echo "<?php print_r(get_loaded_extensions()); ?>" | sudo tee /var/www/html/info.php
  curl http://10.0.2.15/info.php
  ```
  **Expected:** Required extensions (e.g., `mysqli`, `curl`) are installed.

- **Check Configuration:**
  ```bash
  sudo lighttpd -t -f /etc/lighttpd/lighttpd.conf
  ```
  **Expected:** `Syntax OK`

### **MariaDB**
- **Verify Service:**
  ```bash
  sudo systemctl status mariadb
  ```
  **Expected:** `active (running)`

- **Access MariaDB:**
  ```bash
  mariadb
  ```
  **Expected:** MariaDB monitor welcome message.

- **Test Database/User Creation and Privileges:**
  - Create database:
    ```bash
    CREATE DATABASE testuser_db;
    ```
  - Create user:
    ```bash
    CREATE USER testuser@localhost;
    ```
  - Grant privileges:
    ```bash
    GRANT ALL PRIVILEGES ON testuser_db.* TO testuser@localhost;
    FLUSH PRIVILEGES;
    ```

- **Test Connection:**
  ```bash
  mysql -u testuser -p testuser_db
  ```
  **Expected:** Logged into `testuser_db`.

- **Check Logs:**
  ```bash
  sudo journalctl -u mariadb
  ```
  **Expected:** No recurring errors.

### **PHP**
- **Verify Installation:**
  ```bash
  php -v
  php -m
  ```
  **Expected Installed Modules:** `php-mysql`, `php-curl`, `php-gd`, etc.

- **Check Logs:**
  ```bash
  sudo journalctl -u php*
  ```
  **Expected:** No recurring errors.

### **WordPress**
- **Check Homepage:**
  URL: `http://127.0.0.1:2904/`
  **Expected:** WordPress homepage.

- **Access Admin Dashboard:**
  URL: `http://127.0.0.1:2904/wp-admin`
  **Expected:** Admin panel loads.

- **Test Creating a Post:**
  - Add a new post in the admin panel.
  - **Expected:** Post appears correctly.

- **Test Media Uploads:**
  - Upload a file in Media > Add New.
  - **Expected:** File uploads without errors.

- **Test Plugin Installation:**
  - Install and activate a plugin (e.g., `Hello Dolly`).
  - **Expected:** Plugin works as expected.

- **Test Theme Functionality:**
  - Switch to another theme (e.g., `Twenty Twenty-Three`).
  - **Expected:** New theme applied correctly.

## 4. Free-Choice Service (1 Point)

### **Docker**
- **What is Docker?**
  `"Docker is an open-source platform for deploying, scaling, and managing applications using lightweight containers."`

- **Usage in Project:**
  - Simplifies service deployment.
  - Containers ensure consistency and independence.

- **Reason for Choice:**
  `"Docker is a key tool for future projects, especially in cybersecurity. It provides isolation and sandboxing, making it ideal for testing and analyzing potentially harmful software."`

## 5. Test Docker Service

### **Test Command:**
```bash
docker run hello-world
```
**Expected Output:**
```bash
Hello World!
```


