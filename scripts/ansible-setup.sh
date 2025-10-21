#!/bin/bash

# Load colors if available
if [ -f "/vagrant/colors.sh" ]; then
    source /vagrant/colors.sh
else
    # Fallback colors
    RESET_COLOR='\033[0m'
    Black='\033[0;30m'  Red='\033[0;31m'     Green='\033[0;32m'  Yellow='\033[0;33m'
    Blue='\033[0;34m'   Purple='\033[0;35m'  Cyan='\033[0;36m'   White='\033[0;37m'
    BBlack='\033[1;30m' BRed='\033[1;31m'    BGreen='\033[1;32m' BYellow='\033[1;33m'
    BBlue='\033[1;34m'  BPurple='\033[1;35m' BCyan='\033[1;36m'  BWhite='\033[1;37m'
    UBlack='\033[4;30m' URed='\033[4;31m'    UGreen='\033[4;32m' UYellow='\033[4;33m'
    UBlue='\033[4;34m'  UPurple='\033[4;35m' UCyan='\033[4;36m'  UWhite='\033[4;37m'
    On_Black='\033[40m' On_Red='\033[41m'    On_Green='\033[42m' On_Yellow='\033[43m'
    On_Blue='\033[44m'  On_Purple='\033[45m' On_Cyan='\033[46m'  On_White='\033[47m'
    IBlack='\033[0;90m' IRed='\033[0;91m' IGreen='\033[0;92m' IYellow='\033[0;93m'
    IBlue='\033[0;94m' IPurple='\033[0;95m' ICyan='\033[0;96m' IWhite='\033[0;97m'
    BIBlack='\033[1;90m' BIRed='\033[1;91m' BIGreen='\033[1;92m' BIYellow='\033[1;93m'
    BIBlue='\033[1;94m' BIPurple='\033[1;95m' BICyan='\033[1;96m' BIWhite='\033[1;97m'
    On_IBlack='\033[0;100m' On_IRed='\033[0;101m' On_IGreen='\033[0;102m' On_IYellow='\033[0;103m'
    On_IBlue='\033[0;104m' On_IPurple='\033[0;105m' On_ICyan='\033[0;106m' On_IWhite='\033[0;107m'
fi

echo -e "${BGreen}"
echo -e "╔══════════════════════════════════════════════════════════════╗"
echo -e "║                                                              ║"
echo -e "║                  Ansible Lab Auto-Setup                      ║"
echo -e "║                                                              ║"
echo -e "╚══════════════════════════════════════════════════════════════╝"
echo -e "${RESET_COLOR}"

# Wait for all VMs to be ready
echo -e "${BYellow}[*] Waiting for all VMs to be ready...${RESET_COLOR}"
sleep 30

# Install Ansible
echo -e "${BBlue}[*] Installing Ansible...${RESET_COLOR}"

# Remove any existing Ansible installation
sudo apt remove -y ansible ansible-core 2>/dev/null || true

# Update package list
sudo apt update

# Install Ansible from Ubuntu repositories (simpler and more reliable)
echo -e "${Yellow}   Installing Ansible from Ubuntu repositories...${RESET_COLOR}"
sudo apt install -y ansible

# Verify installation
if command -v ansible &> /dev/null; then
    echo -e "${Green}   ✓ Ansible $(ansible --version | head -n1) installed successfully${RESET_COLOR}"
else
    echo -e "${Red}   ✗ Ansible installation failed${RESET_COLOR}"
    exit 1
fi

# Setup SSH keys
echo -e "${BBlue}[*] Setting up SSH key authentication...${RESET_COLOR}"

# Function to copy SSH key with retries
copy_ssh_key() {
    local host=$1
    local max_attempts=5
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo -e "${Yellow}   Attempt $attempt to copy SSH key to $host${RESET_COLOR}"
        if sshpass -p 'vagrant' ssh-copy-id -o StrictHostKeyChecking=no -o ConnectTimeout=10 vagrant@$host; then
            echo -e "${Green}   ✓ Successfully copied SSH key to $host${RESET_COLOR}"
            return 0
        else
            echo -e "${Red}   ✗ Failed to copy SSH key to $host, attempt $attempt/$max_attempts${RESET_COLOR}"
            sleep 10
            ((attempt++))
        fi
    done
    echo -e "${Red}   ✗ Failed to copy SSH key to $host after $max_attempts attempts${RESET_COLOR}"
    return 1
}

# Test basic connectivity first
echo -e "${Cyan}   Testing basic VM connectivity...${RESET_COLOR}"
ping -c 2 192.168.56.11 > /dev/null && echo -e "${Green}   ✓ Ubuntu host reachable${RESET_COLOR}" || echo -e "${Yellow}   ! Ubuntu host not reachable yet${RESET_COLOR}"
ping -c 2 192.168.56.12 > /dev/null && echo -e "${Green}   ✓ Rocky host reachable${RESET_COLOR}" || echo -e "${Yellow}   ! Rocky host not reachable yet${RESET_COLOR}"

# Copy SSH key to Ubuntu host
copy_ssh_key 192.168.56.11

# Copy SSH key to Rocky host  
copy_ssh_key 192.168.56.12

echo -e "${Green}   ✓ SSH key setup complete${RESET_COLOR}"

# Create Ansible inventory
echo -e "${BBlue}[*] Creating Ansible inventory...${RESET_COLOR}"

cat > /home/vagrant/ansible/inventory << 'EOF'
[ubuntu_hosts]
ubuntu-host ansible_host=192.168.56.11 ansible_user=vagrant

[rocky_hosts]
rocky-host ansible_host=192.168.56.12 ansible_user=vagrant ansible_python_interpreter=/usr/bin/python3.6

[all_hosts:children]
ubuntu_hosts
rocky_hosts

[all_hosts:vars]
ansible_ssh_private_key_file=/home/vagrant/.ssh/id_rsa
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF

echo -e "${Green}   ✓ Inventory file created${RESET_COLOR}"

# Create Ansible configuration
echo -e "${BBlue}[*] Creating Ansible configuration...${RESET_COLOR}"

cat > /home/vagrant/ansible/ansible.cfg << 'EOF'
[defaults]
inventory = inventory
host_key_checking = False
remote_user = vagrant
private_key_file = /home/vagrant/.ssh/id_rsa

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
EOF

echo -e "${Green}   ✓ Ansible configuration created${RESET_COLOR}"

# Test connectivity
echo -e "${BBlue}[*] Testing Ansible connectivity...${RESET_COLOR}"

cd /home/vagrant/ansible

# Test connectivity
if ansible all -m ping; then
    echo -e "${BGreen}"

    echo -e "Ansible Lab is Ready! ✔"
    echo -e "${RESET_COLOR}"
    
    echo -e "${BCyan}Example commands you can run:${RESET_COLOR}"
    echo -e "${Cyan}  ansible all -m setup                           ${RESET_COLOR}# Gather facts"
    echo -e "${Cyan}  ansible ubuntu_hosts -m command -a 'uptime'    ${RESET_COLOR}# Run command on Ubuntu"
    echo -e "${Cyan}  ansible rocky_hosts -m yum -a 'name=htop state=present' --become${RESET_COLOR}  # Install package"
    echo -e "${Cyan}  ansible all -m copy -a 'src=/etc/hosts dest=/tmp/hosts'${RESET_COLOR}  # Copy file"
else
    echo -e "${BRed}"
    echo -e "FAILED!  ✘"
    echo -e "\n        -->Some hosts are not reachable"
    echo -e "${RESET_COLOR}"
    exit 1
fi
