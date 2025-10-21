<h1 align="center"> Vagrantfile Commands </h1>

### Quick start
```bash
# initialize a project (creates Vagrantfile if missing)
vagrant init hashicorp/bionic64

# start VMs defined in the Vagrantfile
vagrant up

# SSH into a VM (name from Vagrantfile, e.g., master)
vagrant ssh master
```

### Common lifecycle
```bash
# start or create VMs
vagrant up

# show current VM states
vagrant status

# gracefully shutdown VMs
vagrant halt

# reboot VMs
vagrant reload

# reload and re-run provisioners
vagrant reload --provision

# run provisioners without rebooting
vagrant provision

# destroy VMs and their disks (irreversible)
vagrant destroy -f
```

### Multi-machine examples (for on-prem k8s clusters)
```bash
# bring up specific nodes
vagrant up master worker1 worker2

# SSH into nodes
vagrant ssh master
vagrant ssh worker1
vagrant ssh worker2
```

### Boxes
```bash
# list installed boxes
vagrant box list

# add a box
vagrant box add generic/ubuntu2204

# remove a box
vagrant box remove generic/ubuntu2204

# update boxes used by the environment
vagrant box update
```

### Plugins
```bash
vagrant plugin list
vagrant plugin install vagrant-disksize
vagrant plugin uninstall vagrant-disksize
```

### Snapshots (provider-dependent)
```bash
vagrant snapshot save baseline
vagrant snapshot list
vagrant snapshot restore baseline
vagrant snapshot delete baseline
```

### Sync & packaging
```bash
# sync project files into guest immediately
vagrant rsync

# watch and sync continuously
vagrant rsync-auto

# package a running VM into a .box file
vagrant package --output k8s-node.box
```

### Diagnostics
```bash
vagrant version
vagrant validate
vagrant global-status
```


