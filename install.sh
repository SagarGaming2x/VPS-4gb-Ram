#!/bin/bash

# ==============================================================================
# 🌟 PIECLOUD AUTO-INSTALLER SCRIPT 🌟
# ==============================================================================

# Custom Colors setup
RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
PURPLE='\033[1;35m'
NC='\033[0m' # No Color

clear
echo -e "${PURPLE}======================================================${NC}"
echo -e "${CYAN}        🚀 WELCOME TO PIECLOUD VPS SETUP 🚀           ${NC}"
echo -e "${PURPLE}======================================================${NC}\n"

# Step 1: Update & Upgrade (Logs Visible)
echo -e "${YELLOW}[⏳] Updating and Upgrading VPS packages... (Showing Logs)${NC}"
sleep 1
apt update -y && apt upgrade -y
echo -e "${GREEN}[✅] System Updated Successfully!\n${NC}"

# Step 2: Install Dependencies
echo -e "${YELLOW}[⏳] Installing Neofetch, Screenfetch & Speedtest...${NC}"
sleep 1
apt install neofetch screenfetch curl -y
# Properly installing speedtest via snap (No -y flag)
snap install speedtest
echo -e "${GREEN}[✅] Dependencies Installed Successfully!\n${NC}"

# Step 3: Custom Neofetch Branding (PieCloud Flex)
echo -e "${YELLOW}[⏳] Applying PieCloud Custom Branding & Stealth Mode...${NC}"
# Generate config file silently first
neofetch > /dev/null 2>&1
# Replace hardware info with Custom PieCloud Info (Fixed sed delimiters)
sed -i 's/info "Host" model/prin "Host" "PieCloud Hosting"/g' ~/.config/neofetch/config.conf
sed -i 's/info "Kernel" kernel/prin "Kernel" "6.17.0-1010"/g' ~/.config/neofetch/config.conf
sed -i 's|info "GPU" gpu|prin "GPU" "Intel Corporation 82371AB/EB/MB PIIX4 ACPI (rev 08)"|g' ~/.config/neofetch/config.conf

# Create a clean dedicated stealth file to prevent .bashrc duplicates
cat << 'EOF' > ~/.piecloud_stealth.sh
# ==========================================
# PIECLOUD ALIASES & STEALTH FILTERS
# ==========================================
alias screenfetch='/usr/bin/screenfetch | sed "s/-aws//g" | sed "/Amazon.com/d"'
alias speedtest="command speedtest | awk -v RS='[\r\n]' '{gsub(/Amazon.com/, \"Data Center India Limited\"); gsub(/Tata Play Fiber/, \"KVM Service\"); printf \"%s%s\", \$0, RT; fflush()}'"

uname() { command uname "$@" | sed 's/-aws//g; s/aws//gi'; }
lspci() { command lspci "$@" | sed 's/Amazon.com, Inc./Data Center India Limited/g; s/Amazon EC2/Data Center India Limited/g; s/Amazon/Data Center India Limited/g'; }
lshw() { command lshw "$@" | sed 's/Amazon.com, Inc./Data Center India Limited/g; s/Amazon EC2/Data Center India Limited/g; s/Amazon/Data Center India Limited/g; s/-aws//g; s/aws//gi'; }
cat() {
    if [ -t 1 ]; then
        command cat "$@" | sed 's/-aws//g; s/Amazon.com, Inc./Data Center India Limited/g; s/Amazon EC2/Data Center India Limited/g; s/Amazon/Data Center India Limited/g; s/\.ec2//g'
    else
        command cat "$@"
    fi
}
dmesg() { command dmesg "$@" | sed 's/Amazon.com, Inc./Data Center India Limited/gi; s/Amazon EC2/Data Center India Limited/gi; s/Amazon/Data Center India Limited/gi; s/-aws//gi'; }
dmidecode() { command dmidecode "$@" | sed 's/Amazon.com, Inc./Data Center India Limited/gi; s/Amazon EC2/Data Center India Limited/gi; s/Amazon/Data Center India Limited/gi'; }
systemctl() { command systemctl "$@" | sed 's/amazon-ssm-agent/piecloud-core-agent/gi; s/Amazon SSM Agent/PieCloud Core Management Agent/gi'; }
hostname() { command hostname "$@" | sed 's/\.ec2\.internal//gi; s/\.compute\.internal//gi; s/\.aws//gi'; }
EOF

# Link the stealth file to .bashrc only if it doesn't exist
if ! grep -q "source ~/.piecloud_stealth.sh" ~/.bashrc; then
    echo -e "\n# PieCloud Stealth Logic\nsource ~/.piecloud_stealth.sh" >> ~/.bashrc
fi

echo -e "${GREEN}[✅] Custom Branding & Stealth Mode Applied!\n${NC}"

# Step 4: Run Neofetch
echo -e "${CYAN}👇 System Information 👇${NC}"
neofetch
echo -e "\n"

# Step 5: Custom Hostname Input with Validation
NEW_HOSTNAME=""
while [[ -z "$NEW_HOSTNAME" ]]; do
    echo -e "${CYAN}📝 Enter the new Hostname for this VPS (e.g., piecloud, node-1):${NC}"
    read -p "👉 " NEW_HOSTNAME
    if [[ -z "$NEW_HOSTNAME" ]]; then
        echo -e "${RED}[❌] Hostname cannot be empty! Please enter a valid name.${NC}\n"
    fi
done

echo -e "${YELLOW}[⏳] Changing Hostname to '$NEW_HOSTNAME'...${NC}"
hostnamectl set-hostname "$NEW_HOSTNAME"
hostname "$NEW_HOSTNAME"
echo -e "${GREEN}[✅] Hostname successfully changed to '$NEW_HOSTNAME'!\n${NC}"

# Step 6: Setup Root Password with Validation
echo -e "${CYAN}🔑 Enter New Password for Root User:${NC}"
passwd root
while [ $? -ne 0 ]; do
    echo -e "${RED}[❌] Password update failed (Maybe you left it empty or didn't match). Try again!${NC}"
    passwd root
done
echo -e "${GREEN}[✅] Root Password Updated!\n${NC}"

# Step 7: SSH Dependencies Setup
echo -e "${YELLOW}[⏳] Setting up SSH Dependencies & Rules...${NC}"
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/*.conf 2>/dev/null
echo -e "${GREEN}[✅] SSH Configured to allow Password Logins!\n${NC}"

# Step 8: Reload Services
echo -e "${YELLOW}[⏳] Reloading System Services...${NC}"
systemctl daemon-reload
systemctl restart ssh
echo -e "${GREEN}[✅] SSH Service Restarted!\n${NC}"

# Step 9: Clear History Prompt
echo -e "${CYAN}🧹 Do you want to clear previous commands history? (yes/no):${NC}"
read -p "👉 " clear_cmd

if [[ "$clear_cmd" == "yes" || "$clear_cmd" == "y" ]]; then
    cat /dev/null > ~/.bash_history
    history -cw
    echo -e "${GREEN}[✅] Terminal History Cleared!\n${NC}"
else
    echo -e "${YELLOW}[➡] History kept intact.\n${NC}"
fi

# Step 10: Final Thank You Message & Reload Shell
echo -e "${PURPLE}======================================================${NC}"
echo -e "${GREEN}      🎉 SETUP COMPLETE! THANK YOU FOR CHOOSING 🎉    ${NC}"
echo -e "${CYAN}                    PIECLOUD!                         ${NC}"
echo -e "${PURPLE}======================================================${NC}"
echo -e "${YELLOW}💡 Automatically reloading terminal to apply all changes...${NC}\n"
sleep 2

# This will auto-reload the terminal with new hostname and settings!
exec bash
