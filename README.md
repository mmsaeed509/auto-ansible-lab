# Automated Ansible Lab Setup with Vagrant

> This setup creates a fully automated 3-VM Ansible lab environment using Vagrant and VirtualBox. 
> Perfect for learning and practicing Ansible automation on both Linux and Windows hosts.

### VM Specs

- **Ansible Manager**: Ubuntu 22.04 (jammy64), IP: 192.168.56.10
- **Ubuntu Host**: Ubuntu 22.04 (jammy64), IP: 192.168.56.11  
- **Rocky Host**: Rocky Linux 8, IP: 192.168.56.12
- **RAM**: `2GB`
- **CPUs**: `2 cores`
- **Size**: `15GB`

### Prerequisites

- [**`Vagrant`**](https://www.vagrantup.com)
- [**`VirtualBox`**](https://www.virtualbox.org)
- At least `6GB` RAM available on host machine
- `45GB+` free disk space

---

### One-Command Setup

```bash
vagrant up
```

### Accessing the Lab

1. **SSH into the manager machine**:
   ```bash
   vagrant ssh ansible-manager
   ```

2. **Navigate to ansible directory**:
   ```bash
   cd /home/vagrant/ansible
   export PATH=$PATH:/home/vagrant/.local/bin
   ```

3. **Test connectivity**:
   ```bash
   ansible all -m ping
   ```
