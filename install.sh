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

# Step 2: Install Neofetch
echo -e "${YELLOW}[⏳] Installing Neofetch...${NC}"
sleep 1
apt install neofetch -y
apt install screenfetch -y
echo -e "${GREEN}[✅] Neofetch Installed Successfully!\n${NC}"

# Step 3: Custom Neofetch Branding (PieCloud Flex)
echo -e "${YELLOW}[⏳] Applying PieCloud Custom Branding...${NC}"
# Generate config file silently first
neofetch > /dev/null 2>&1
# Replace hardware info with Custom PieCloud Info
sed -i 's/info "Host" model/prin "Host" "PieCloud Hosting"/g' ~/.config/neofetch/config.conf
sed -i 's/info "Kernel" kernel/prin "Kernel" "6.17.0-1010"/g' ~/.config/neofetch/config.conf
sed -i 's/info "GPU" gpu/prin "GPU" "PieCloud Dedicated GPU"/g' ~/.config/neofetch/config.conf
sed -i '/alias screenfetch=/d' ~/.bashrc && echo "alias screenfetch='/usr/bin/screenfetch | sed \"s/-aws//g\" | sed \"/Amazon.com/d\"'" >> ~/.bashrc && source ~/.bashrc
echo -e "${GREEN}[✅] Custom Branding Applied!\n${NC}"

# Step 4: Run Neofetch (Ab naya wala dikhega!)
echo -e "${CYAN}👇 System Information 👇${NC}"
neofetch
echo -e "\n"

# Step 5: Custom Hostname Input
echo -e "${CYAN}📝 Enter the new Hostname for this VPS (e.g., piecloud, node-1):${NC}"
read -p "👉 " NEW_HOSTNAME
echo -e "${YELLOW}[⏳] Changing Hostname to '$NEW_HOSTNAME'...${NC}"
hostnamectl set-hostname "$NEW_HOSTNAME"
hostname "$NEW_HOSTNAME"
echo -e "${GREEN}[✅] Hostname successfully changed to '$NEW_HOSTNAME'!\n${NC}"

# Step 6: Setup Root Password
echo -e "${CYAN}🔑 Enter New Password for Root User:${NC}"
passwd root
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
    history -c
    echo -e "${GREEN}[✅] Terminal History Cleared!\n${NC}"
else
    echo -e "${YELLOW}[➡] History kept intact.\n${NC}"
fi

# Step 10: Final Thank You Message
echo -e "${PURPLE}======================================================${NC}"
echo -e "${GREEN}      🎉 SETUP COMPLETE! THANK YOU FOR CHOOSING 🎉    ${NC}"
echo -e "${CYAN}                    PIECLOUD!                         ${NC}"
echo -e "${PURPLE}======================================================${NC}"
echo -e "${YELLOW}💡 Note: Type 'bash' and hit Enter to see your new hostname '$NEW_HOSTNAME' on screen!${NC}\n"
