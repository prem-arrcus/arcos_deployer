## KVM Setup on Debian
### Prerequisites
#### Setup sudo access for current user
Install sudo
```bash
$ su -c "apt install sudo; usermod -aG sudo $USER"
```
#### Enable passwordless sudo
```bash
$ echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/${USER}
```
#### Verify passwordless sudo access
```bash
❯ sudo echo Test
Test
```

### Install Libvirt and virt-install
#### Install the needed packages
```bash
$ sudo apt install curl bridge-utils
$ sudo apt install --no-install-recommends qemu-system-x86 libvirt-clients libvirt-daemon-system virtinst
```

#### Setup the current user to use libvirt
```bash
$ sudo usermod -aG libvirt $USER
```

#### Validate libvirt installation
Logout and log back in and check the output of the command `virt-host-validate`
```bash
❯ sudo virt-host-validate qemu
  QEMU: Checking for hardware virtualization                                 : PASS (SVM)
  QEMU: Checking if device '/dev/kvm' exists                                 : PASS
  QEMU: Checking if device '/dev/kvm' is accessible                          : PASS
  QEMU: Checking if device '/dev/vhost-net' exists                           : PASS
  QEMU: Checking if device '/dev/net/tun' exists                             : PASS
  QEMU: Checking for cgroup 'cpu' controller support                         : PASS
  QEMU: Checking for cgroup 'cpuacct' controller support                     : PASS
  QEMU: Checking for cgroup 'cpuset' controller support                      : PASS
  QEMU: Checking for cgroup 'memory' controller support                      : PASS
  QEMU: Checking for cgroup 'devices' controller support                     : PASS
  QEMU: Checking for cgroup 'blkio' controller support                       : PASS
  QEMU: Checking for device assignment IOMMU support                         : PASS (IVRS)
  QEMU: Checking if IOMMU is enabled by kernel                               : PASS
  QEMU: Checking for secure guest support                                    : WARN (None of SEV, SEV-ES, SEV-SNP, TDX available)
```

### Launch Arcos VMs
#### Script usage
```bash
❯ ./launch_arcos.sh


Usage:
~~~~~~
    launch_arcos.sh
        [--disk=<disk>]
        [--name=<name>]
        [--tb=<tb>]
        [--cpus=<cpus=2>]
        [--mem=<mem=4096>]
        [--networks=<networks>]
        [--bridges=<bridges>]
        [--pci=<pci>]
        [--extra_args=<extra args>]
        [--sim_dir=<sim dir>]
        [--image_dir=<image dir>]
        [--cleanup=<cleanup>]


Examples:
~~~~~~~~~
    launch_arcos.sh --disk <disk.qcow2>
    launch_arcos.sh --name rtr1 --tb TB1 --disk <disk.qcow2>
    launch_arcos.sh --name rtr1 --tb TB1 --disk <disk.qcow2> --networks mynet1,mynet2
    launch_arcos.sh --name rtr1 --tb TB1 --disk <disk.qcow2> --bridges br1,br2
    launch_arcos.sh --name rtr1 --tb TB1 --disk <disk.qcow2> --pci pci_0000_31_00_0,pci_0000_31_00_1
    launch_arcos.sh --name rtr1 --tb TB1 --cleanup
    launch_arcos.sh --tb TB1 --cleanup
```

#### Run the launcher
Note: The launcher starts the serial console for the launched VM. Press `Ctrl+]` to get out of the serial console

```bash
$ DISK=arcos-sa-1767687415.e26acb74543a2701717a2db9dc4e65f48d36c23d.kvm.qcow2
$ ./launch_arcos.sh --tb Prem-TB1 --name rtr1 --disk $DISK --cpus 4 --mem 16384 --bridges br1,br2
$ ./launch_arcos.sh --tb Prem-TB1 --name rtr2 --disk $DISK --cpus 4 --mem 16384 --bridges br1,br2
```

#### Sample Logs
Sample deployment logs can be seen [here](https://html-preview.github.io/?url=https://github.com/prem-arrcus/arcos_deployer/blob/prem-test/logs/sample_log.html)

#### Cleanup
```bash
❯ ./launch_arcos.sh --tb Prem-TB1 --cleanup

Parsing cli args
    Arg: name: rtr2
    Arg: tb: Prem-TB1
    Arg: cleanup: 1

Destroying VMs
 -- VM Prem-TB1-rtr1
Domain 'Prem-TB1-rtr1' has been undefined

 -- VM Prem-TB1-rtr2
Domain 'Prem-TB1-rtr2' has been undefined

Removing sim_dir /space/prem/sim_dir/Prem-TB1
Removing bridges

Cleanup succeeded
```
