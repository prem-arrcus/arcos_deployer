#!/usr/bin/env bash

set -ex
[ "$DEBUG" == "1" ] && set -x

# Load needed libs
script_dir="$(dirname "$(realpath $0)")"
echo $script_dir
source $script_dir/lib/init
source $script_dir/lib/pda

# Usage
usage() {
  pda::usage $0 "disk" "name" "tb" "cpus" "mem" "networks" "bridges" "pci" \
    "extra_args" "base_dir" "sim_dir" "image_dir" "cleanup"

  disk="<disk.qcow2>"
  pda::example $0 "--disk <path to $disk> --base_dir /space" \
    "--name rtr1 --disk $disk --image_dir /path/to/my/images" \
    "--name rtr1 --tb TB1 --disk $disk" \
    "--name rtr1 --tb TB1 --disk $disk --networks mynet1,mynet2" \
    "--name rtr1 --tb TB1 --disk $disk --bridges br1,br2" \
    "--name rtr1 --tb TB1 --disk $disk --pci pci_0000_31_00_0,pci_0000_31_00_1" \
    "--name rtr1 --tb TB1 --cleanup" \
    "--tb TB1 --cleanup"
}

# Pre-requisites
source /etc/os-release
if [ "$ID" = "debian" ] || [ "$ID" = "ubuntu" ]; then
  check_pkg() { dpkg -s "$1" &> /dev/null; }
  pkgs="bridge-utils qemu-system-x86 libvirt-clients libvirt-daemon-system virtinst qemu-utils"
elif [ "$ID" = "arch" ] || [ "$ID" = "cachyos" ]; then
  check_pkg() { pacman -Q "$1" &> /dev/null; }
  pkgs="bridge-utils qemu-system-x86 libvirt virt-install qemu-img"
else
  die "Unsupported distro"
fi
for pkg in $pkgs; do
  check_pkg "$pkg" || die "Needed package '$pkg' not installed. Please install it to proceed"
done

# Defaults
export LIBVIRT_DEFAULT_URI="qemu:///system"
extra_args=""

# Parse cli args
cpus=2
mem=4096
pda::parse_cli_args $@

# Init SIM_DIR & IMAGE_DIR
BASE_DIR="/space"
SIM_DIR="${sim_dir:-$BASE_DIR/$USER/sim_dir}/$tb"
IMAGE_DIR="${image_dir:-$BASE_DIR/$USER/arrcus/images}"

if [ -n "$cleanup" ]; then
  [ -n "$tb" ] || die "Testbed name (--tb) arg is mandatory for cleanup"
  vm_ptrn="^${tb}-"
  [ -n "$name" ] && vm_ptrn="^${tb}-${name}\$" || vm_ptrn="^${tb}-"

  # Destroy the VMs
  echo "Destroying VMs"
  for vm in $(virsh list --name | grep "${vm_ptrn}"); do
    echo " -- VM $vm"
    virsh destroy "$vm"
    virsh undefine "$vm"
  done
  for vm in $(virsh list --name --all | grep "${vm_ptrn}"); do
    echo " -- VM $vm"
    virsh undefine "$vm"
  done

  # Delete disks in sim_dir
  if [ -d "$SIM_DIR" ]; then
    echo "Removing sim_dir $SIM_DIR"
    rm -rf "$SIM_DIR"
  fi

  # Destroy any bridges
  echo "Removing bridges"
  for br in $(ip -br link show type bridge | grep "^${tb}-" | cut -f1 -d' ' | xargs); do
    if ! ls "/sys/class/net/$br/" | grep -q lower_; then
      # bridge doesn't have any member intfs and is safe to delete
      echo " -- bridge $br"
      sudo ip link set down dev "$br"
      sudo ip link del "$br"
    fi
  done

  echo
  echo "Cleanup succeeded"
  trap '' EXIT
  exit
fi

# Init defaults after parsing cli argsi
: "${name:=rtr}"
: "${tb:=TB1}"
uname="${tb}-${name}"

# Create SIM_DIR
#echo "Creating SIM_DIR: $SIM_DIR"
mkdir -p "$SIM_DIR" || die "Failed to create SIM_DIR"

# Disk
if [ -n "$disk" ]; then
  [[ "$disk" =~ \.qcow2$ ]] || die "disk $disk is not a valid disk; only qcow2 images are supported"
  if [ ! -f "$disk" ]; then
    if [ -f "${IMAGE_DIR}/${disk}" ]; then
      disk="${IMAGE_DIR}/${disk}"
    else
      die "Disk: $disk not found"
    fi
  fi
  sudo -u libvirt-qemu test -r "$disk" \
    || die "Disk $disk doesn't have read access for libvirt-qemu user"
  my_disk="${SIM_DIR}/${name}.qcow2"
  rm -rf "$my_disk"

  disk_args="path=${my_disk},size=20,backing_store=$disk,backing_format=qcow2,bus=virtio,cache=none"
else
  die "Disk (--disk arg) is mandatory"
fi
echo "Using Disk: $disk"
echo

# Networking
echo "Networks:"
## default mgmt network
# network_args="--network network=default"
network_args="--network network=ztp"
## connect to existing libvirt networks
if [ -n "$networks" ]; then
  echo "Networking"
  for network in ${networks//,/ }; do
    network_args="${network_args} --network network=$network"
  done
fi
## connect to new bridged networks
if [ -n "$bridges" ]; then
  existing_bridges="$(ip -br link show type bridge | cut -f1 -d: | xargs)"
  for net in ${bridges//,/ }; do
    br="${tb}-${net}"
    echo "  -- Bridge: $br"
    network_args="${network_args} --network=bridge=$br"

    # Create bridge if needed
    if ! echo $existing_bridges | grep -q $br; then
      sudo ip link add "$br" type bridge
      sudo ip link set up dev $br
      created_bridges="$created_bridges $br"
    fi
  done
fi
network_args=$(echo ${network_args} | sed -E 's/( --|$)/,model=virtio,driver.iommu=on \1/g')

# Networking: PCI-Passthru
if [ -n "$pci" ]; then
  for pci_dev in ${pci//,/ }; do
    pci_dev=${pci_dev//[:.]/_}
    virsh nodedev-list | grep -q ^${pci_dev} || die "Invalid pci dev $pci_dev specified for passthrough"
    network_args="${network_args} --hostdev $pci_dev"
  done
fi
echo "Network args: $network_args"
echo

virt-install \
  --connect qemu:///system \
  --machine q35 --virt-type kvm \
  --iommu intel,driver.intremap=on,driver.caching_mode=on,driver.eim=on \
  --name "${uname}" \
  --virt-type kvm \
  --os-variant debiantesting \
  --cpu=host-model --features acpi=on,apic=on,pae=on,ioapic.driver=qemu \
  --vcpus $cpus --memory $mem \
  --install no_install=yes \
  --controller type=scsi,model=virtio-scsi,driver.iommu=on \
  --boot hd --disk "${disk_args},target.bus=scsi" \
  --graphics vnc,listen=0.0.0.0 \
  --autoconsole text \
  --controller type=virtio-serial,driver.iommu=on \
  --console=pty,target_type=serial \
  ${network_args} \
  ${extra_args}

echo
echo -n "VM $uname running ... "
echo -n "( vnc: $(ip route get 1 | grep -Po '(?<=src )[^ ]*'):"
echo "$((5900 + $(virsh vncdisplay "$uname" | cut -d: -f2))) )"
