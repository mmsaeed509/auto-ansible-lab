#####################################
#                                   #
#  @author      : 00xWolf           #
#    GitHub    : @mmsaeed509       #
#    Developer : Mahmoud Mohamed   #
#  﫥  Copyright : Exodia OS         #
#                                   #
#####################################

# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Increase boot timeout for slower VMs
  config.vm.boot_timeout = 600
  
  # Sync scripts directory to all VMs
  config.vm.synced_folder "scripts", "/vagrant", type: "virtualbox"
  
  # Ansible Manager Machine
  config.vm.define "ansible-manager" do |manager|
    manager.vm.box = "ubuntu/jammy64"
    manager.vm.hostname = "ansible-manager"
    manager.vm.network "private_network", ip: "192.168.56.10"
    
    manager.vm.provider "virtualbox" do |vb|
      vb.name = "ansible-manager"
      vb.memory = "2048"  # 2GB RAM
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--vram", "16"]
    end
    
    # Basic setup and install dependencies
    manager.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y software-properties-common sshpass python3-pip
      
      # Generate SSH key for ansible user
      sudo -u vagrant ssh-keygen -t rsa -b 2048 -f /home/vagrant/.ssh/id_rsa -N ""
      
      # Create ansible directory
      mkdir -p /home/vagrant/ansible
      chown vagrant:vagrant /home/vagrant/ansible
      
      # Make scripts executable
      chmod +x /vagrant/*.sh
    SHELL
    
    # Run Ansible setup script (this will run last due to VM definition order)
    manager.vm.provision "shell", path: "scripts/ansible-setup.sh", privileged: false
  end

  # Ubuntu Host Machine
  config.vm.define "ubuntu-host" do |ubuntu|
    ubuntu.vm.box = "ubuntu/jammy64"
    ubuntu.vm.hostname = "ubuntu-host"
    ubuntu.vm.network "private_network", ip: "192.168.56.11"
    
    ubuntu.vm.provider "virtualbox" do |vb|
      vb.name = "ubuntu-host"
      vb.memory = "2048"  # 2GB RAM
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--vram", "16"]
    end
    
    ubuntu.vm.provision "shell", inline: <<-SHELL
      apt-get update
      
      # Configure SSH properly
      sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
      sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
      sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
      sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
      
      # Ensure the changes are applied
      echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
      echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
      
      systemctl restart ssh
      systemctl enable ssh
      
      # Make scripts executable
      chmod +x /vagrant/*.sh
    SHELL
    
    # Additional SSH fix if needed
    ubuntu.vm.provision "shell", path: "scripts/fix-ubuntu-ssh.sh"
  end

  # Rocky Linux Host Machine
  config.vm.define "rocky-host" do |rocky|
    rocky.vm.box = "generic/rocky8"
    rocky.vm.hostname = "rocky-host"
    rocky.vm.network "private_network", ip: "192.168.56.12"
    
    rocky.vm.provider "virtualbox" do |vb|
      vb.name = "rocky-host"
      vb.memory = "2048"  # 2GB RAM
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--vram", "16"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    end
    
    rocky.vm.provision "shell", inline: <<-SHELL
      # Update system
      dnf update -y
      
      # Configure SSH
      sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
      sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
      sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
      sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
      
      # Restart SSH service
      systemctl restart sshd
      systemctl enable sshd
      
      # Ensure firewall allows SSH
      firewall-cmd --permanent --add-service=ssh
      firewall-cmd --reload
      
      # Make scripts executable
      chmod +x /vagrant/*.sh
    SHELL
  end
end