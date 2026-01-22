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
```
❯ ./launch_arcos.sh --tb Prem-TB1 --name rtr2 --disk arcos-sa-1767687415.e26acb74543a2701717a2db9dc4e65f48d36c23d.kvm.qcow2 --cpus 4 --mem 16384 --bridges br1,br2 | tee log
[0;32mParsing cli args[0m
    Arg: tb: Prem-TB1
    Arg: name: rtr2
    Arg: disk: arcos-sa-1767687415.e26acb74543a2701717a2db9dc4e65f48d36c23d.kvm.qcow2
    Arg: cpus: 4
    Arg: mem: 16384
    Arg: bridges: br1,br2

Using Disk: /space/prem/arrcus/images/arcos-sa-1767687415.e26acb74543a2701717a2db9dc4e65f48d36c23d.kvm.qcow2

Networks:
  -- Bridge: Prem-TB1-br1
  -- Bridge: Prem-TB1-br2
Network args: --network network=ztp,model=virtio,driver.iommu=on  --network=bridge=Prem-TB1-br1,model=virtio,driver.iommu=on  --network=bridge=Prem-TB1-br2,model=virtio,driver.iommu=on 


Starting install...
Allocating 'rtr2.qcow2'                                     |  20 GB  00:00     
Creating domain...                                          |         00:00     
Connected to domain 'Prem-TB1-rtr2'
Escape character is ^] (Ctrl + ])
No EFI environment detected.
early console in extract_kernel
input_data: 0x00000000029a02ee
input_len: 0x0000000000ba31be
output: 0x0000000001000000
output_len: 0x00000000024fd960
kernel_total_size: 0x0000000002426000
needed_size: 0x0000000002600000
trampoline_32bit: 0x000000000009d000

Decompressing Linux... Parsing ELF... done.
Booting the kernel.
[    0.000000] Linux version 6.1.55-arrcus (builder@aminor) (gcc (Debian 12.2.0-14+deb12u1) 12.2.0, GNU ld (GNU Binutils for Debian) 2.40) #1765152226 SMP PREEMPT_DYNAMIC Mon Dec  8 02:25:58 UTC 2025
[    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-6.1.55-arrcus root=UUID=43e44b67-14f3-4135-a531-33ab11c87f94 ro swiotlb=65536 console=ttyS0 earlyprintk=ttyS0 net.ifnames=0 biosdevname=0 crashkernel=384M-:128M
[    0.000000] BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000007ffdbfff] usable
[    0.000000] BIOS-e820: [mem 0x000000007ffdc000-0x000000007fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000b0000000-0x00000000bfffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000047fffffff] usable
[    0.000000] BIOS-e820: [mem 0x000000fd00000000-0x000000ffffffffff] reserved
[    0.000000] printk: bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.8 present.
[    0.000000] DMI: QEMU Standard PC (Q35 + ICH9, 2009), BIOS Arch Linux 1.17.0-2-2 04/01/2014
[    0.000000] Hypervisor detected: KVM
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000001] kvm-clock: using sched offset of 937782985 cycles
[    0.001012] clocksource: kvm-clock: mask: 0xffffffffffffffff max_cycles: 0x1cd42e4dffb, max_idle_ns: 881590591483 ns
[    0.004180] tsc: Detected 3293.820 MHz processor
[    0.005516] last_pfn = 0x480000 max_arch_pfn = 0x400000000
[    0.006627] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WP  UC- WT  
[    0.007975] last_pfn = 0x7ffdc max_arch_pfn = 0x400000000
[    0.010635] found SMP MP-table at [mem 0x000f6670-0x000f667f]
[    0.011751] Using GB pages for direct mapping
[    0.012847] RAMDISK: [mem 0x36e6f000-0x3772efff]
[    0.013745] ACPI: Early table checksum verification disabled
[    0.014844] ACPI: RSDP 0x00000000000F6630 000014 (v00 BOCHS )
[    0.015950] ACPI: RSDT 0x000000007FFE2BF5 000038 (v01 BOCHS  BXPC     00000001 BXPC 00000001)
[    0.017626] ACPI: FACP 0x000000007FFE292D 0000F4 (v03 BOCHS  BXPC     00000001 BXPC 00000001)
[    0.019289] ACPI: DSDT 0x000000007FFDFDC0 002B6D (v01 BOCHS  BXPC     00000001 BXPC 00000001)
[    0.020972] ACPI: FACS 0x000000007FFDFD80 000040
[    0.021879] ACPI: APIC 0x000000007FFE2A21 000090 (v03 BOCHS  BXPC     00000001 BXPC 00000001)
[    0.023528] ACPI: MCFG 0x000000007FFE2AB1 00003C (v01 BOCHS  BXPC     00000001 BXPC 00000001)
[    0.025188] ACPI: DMAR 0x000000007FFE2AED 0000E0 (v01 BOCHS  BXPC     00000001 BXPC 00000001)
[    0.026850] ACPI: WAET 0x000000007FFE2BCD 000028 (v01 BOCHS  BXPC     00000001 BXPC 00000001)
[    0.028523] ACPI: Reserving FACP table memory at [mem 0x7ffe292d-0x7ffe2a20]
[    0.029905] ACPI: Reserving DSDT table memory at [mem 0x7ffdfdc0-0x7ffe292c]
[    0.031291] ACPI: Reserving FACS table memory at [mem 0x7ffdfd80-0x7ffdfdbf]
[    0.032778] ACPI: Reserving APIC table memory at [mem 0x7ffe2a21-0x7ffe2ab0]
[    0.034123] ACPI: Reserving MCFG table memory at [mem 0x7ffe2ab1-0x7ffe2aec]
[    0.035482] ACPI: Reserving DMAR table memory at [mem 0x7ffe2aed-0x7ffe2bcc]
[    0.036836] ACPI: Reserving WAET table memory at [mem 0x7ffe2bcd-0x7ffe2bf4]
[    0.038677] No NUMA configuration found
[    0.039423] Faking a node at [mem 0x0000000000000000-0x000000047fffffff]
[    0.040705] NODE_DATA(0) allocated [mem 0x47fffa000-0x47fffdfff]
[    0.041892] Reserving 128MB of memory at 1904MB for crashkernel (System RAM: 16383MB)
[    0.043427] Zone ranges:
[    0.043919]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.045131]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
[    0.046335]   Normal   [mem 0x0000000100000000-0x000000047fffffff]
[    0.047544] Movable zone start for each node
[    0.048371] Early memory node ranges
[    0.049058]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.050276]   node   0: [mem 0x0000000000100000-0x000000007ffdbfff]
[    0.051497]   node   0: [mem 0x0000000100000000-0x000000047fffffff]
[    0.052705] Initmem setup node 0 [mem 0x0000000000001000-0x000000047fffffff]
[    0.054187] On node 0, zone DMA: 1 pages in unavailable ranges
[    0.054206] On node 0, zone DMA: 97 pages in unavailable ranges
[    0.084138] On node 0, zone Normal: 36 pages in unavailable ranges
[    0.088230] ACPI: PM-Timer IO Port: 0x608
[    0.090204] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.091403] IOAPIC[0]: apic_id 0, version 32, address 0xfec00000, GSI 0-23
[    0.092765] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.094004] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.095285] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.096565] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.097888] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.099227] ACPI: Using ACPI (MADT) for SMP configuration information
[    0.100479] TSC deadline timer available
[    0.101261] smpboot: Allowing 4 CPUs, 0 hotplug CPUs
[    0.102268] PM: hibernation: Registered nosave memory: [mem 0x00000000-0x00000fff]
[    0.103767] PM: hibernation: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.105240] PM: hibernation: Registered nosave memory: [mem 0x000a0000-0x000effff]
[    0.106728] PM: hibernation: Registered nosave memory: [mem 0x000f0000-0x000fffff]
[    0.108195] PM: hibernation: Registered nosave memory: [mem 0x7ffdc000-0x7fffffff]
[    0.109698] PM: hibernation: Registered nosave memory: [mem 0x80000000-0xafffffff]
[    0.111181] PM: hibernation: Registered nosave memory: [mem 0xb0000000-0xbfffffff]
[    0.112673] PM: hibernation: Registered nosave memory: [mem 0xc0000000-0xfed1bfff]
[    0.114153] PM: hibernation: Registered nosave memory: [mem 0xfed1c000-0xfed1ffff]
[    0.115631] PM: hibernation: Registered nosave memory: [mem 0xfed20000-0xfeffbfff]
[    0.117117] PM: hibernation: Registered nosave memory: [mem 0xfeffc000-0xfeffffff]
[    0.118605] PM: hibernation: Registered nosave memory: [mem 0xff000000-0xfffbffff]
[    0.120090] PM: hibernation: Registered nosave memory: [mem 0xfffc0000-0xffffffff]
[    0.121589] [mem 0xc0000000-0xfed1bfff] available for PCI devices
[    0.122782] Booting paravirtualized kernel on KVM
[    0.123698] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1910969940391419 ns
[    0.125737] setup_percpu: NR_CPUS:64 nr_cpumask_bits:4 nr_cpu_ids:4 nr_node_ids:1
[    0.127379] percpu: Embedded 55 pages/cpu s186664 r8192 d30424 u524288
[    0.128690] Fallback order for Node 0: 0 
[    0.128691] Built 1 zonelists, mobility grouping on.  Total pages: 4128476
[    0.130836] Policy zone: Normal
[    0.131462] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-6.1.55-arrcus root=UUID=43e44b67-14f3-4135-a531-33ab11c87f94 ro swiotlb=65536 console=ttyS0 earlyprintk=ttyS0 net.ifnames=0 biosdevname=0 crashkernel=384M-:128M
[    0.135333] Unknown kernel command line parameters "BOOT_IMAGE=/boot/vmlinuz-6.1.55-arrcus biosdevname=0", will be passed to user space.
[    0.138863] Dentry cache hash table entries: 2097152 (order: 12, 16777216 bytes, linear)
[    0.141098] Inode-cache hash table entries: 1048576 (order: 11, 8388608 bytes, linear)
[    0.142787] mem auto-init: stack:all(zero), heap alloc:off, heap free:off
[    0.144134] software IO TLB: area num 4.
[    0.183324] Memory: 16178580K/16776680K available (20493K kernel code, 3023K rwdata, 5156K rodata, 1880K init, 3084K bss, 597844K reserved, 0K cma-reserved)
[    0.186140] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
[    0.188331] Dynamic Preempt: voluntary
[    0.189218] rcu: Preemptible hierarchical RCU implementation.
[    0.190362] rcu: 	RCU restricting CPUs from NR_CPUS=64 to nr_cpu_ids=4.
[    0.191669] 	Trampoline variant of Tasks RCU enabled.
[    0.192653] 	Tracing variant of Tasks RCU enabled.
[    0.193586] rcu: RCU calculated value of scheduler-enlistment delay is 100 jiffies.
[    0.195091] rcu: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=4
[    0.197362] NR_IRQS: 4352, nr_irqs: 456, preallocated irqs: 16
[    0.198628] rcu: srcu_init: Setting srcu_struct sizes based on contention.
[    0.212182] Console: colour VGA+ 80x25
[    0.212943] printk: console [ttyS0] enabled
[    0.212943] printk: console [ttyS0] enabled
[    0.214480] printk: bootconsole [earlyser0] disabled
[    0.214480] printk: bootconsole [earlyser0] disabled
[    0.216304] ACPI: Core revision 20220331
[    0.217070] APIC: Switch to symmetric I/O mode setup
[    0.217999] DMAR: Host address width 48
[    0.218718] DMAR: DRHD base: 0x000000fed90000 flags: 0x0
[    0.219804] DMAR: dmar0: reg_base_addr fed90000 ver 1:0 cap d2008c222f0686 ecap f00f5a
[    0.221310] DMAR-IR: IOAPIC id 0 under DRHD base  0xfed90000 IOMMU 0
[    0.222505] DMAR-IR: Queued invalidation will be enabled to support x2apic and Intr-remapping.
[    0.225563] DMAR-IR: Enabled IRQ remapping in x2apic mode
[    0.226583] x2apic enabled
[    0.227118] Switched APIC routing to cluster x2apic.
[    0.234129] tsc: Marking TSC unstable due to TSCs unsynchronized
[    0.235300] Calibrating delay loop (skipped) preset value.. 6587.64 BogoMIPS (lpj=3293820)
[    0.236296] x86/cpu: User Mode Instruction Prevention (UMIP) activated
[    0.236296] Last level iTLB entries: 4KB 512, 2MB 255, 4MB 127
[    0.236296] Last level dTLB entries: 4KB 512, 2MB 255, 4MB 127, 1GB 0
[    0.236296] Spectre V1 : Mitigation: usercopy/swapgs barriers and __user pointer sanitization
[    0.236296] Spectre V2 : Mitigation: Retpolines
[    0.236296] Spectre V2 : Spectre v2 / SpectreRSB mitigation: Filling RSB on context switch
[    0.236296] Spectre V2 : Spectre v2 / SpectreRSB : Filling RSB on VMEXIT
[    0.236296] Spectre V2 : Enabling Restricted Speculation for firmware calls
[    0.236296] Spectre V2 : mitigation: Enabling conditional Indirect Branch Prediction Barrier
[    0.236296] Speculative Store Bypass: Mitigation: Speculative Store Bypass disabled via prctl
[    0.236296] Speculative Return Stack Overflow: Mitigation: safe RET
[    0.236296] x86/fpu: Supporting XSAVE feature 0x001: 'x87 floating point registers'
[    0.236296] x86/fpu: Supporting XSAVE feature 0x002: 'SSE registers'
[    0.236296] x86/fpu: Supporting XSAVE feature 0x004: 'AVX registers'
[    0.236296] x86/fpu: Supporting XSAVE feature 0x200: 'Protection Keys User registers'
[    0.236296] x86/fpu: xstate_offset[2]:  576, xstate_sizes[2]:  256
[    0.236296] x86/fpu: xstate_offset[9]:  832, xstate_sizes[9]:    8
[    0.236296] x86/fpu: Enabled xstate features 0x207, context size is 840 bytes, using 'compacted' format.
[    0.236296] Freeing SMP alternatives memory: 56K
[    0.236296] pid_max: default: 32768 minimum: 301
[    0.236296] LSM: Security Framework initializing
[    0.236296] Mount-cache hash table entries: 32768 (order: 6, 262144 bytes, linear)
[    0.236296] Mountpoint-cache hash table entries: 32768 (order: 6, 262144 bytes, linear)
[    0.236296] smpboot: CPU0: AMD EPYC-Milan Processor (family: 0x19, model: 0x1, stepping: 0x1)
[    0.236360] cblist_init_generic: Setting adjustable number of callback queues.
[    0.237300] cblist_init_generic: Setting shift to 2 and lim to 1.
[    0.238313] cblist_init_generic: Setting adjustable number of callback queues.
[    0.239300] cblist_init_generic: Setting shift to 2 and lim to 1.
[    0.240313] Performance Events: Fam17h+ core perfctr, AMD PMU driver.
[    0.241302] ... version:                0
[    0.242067] ... bit width:              48
[    0.242299] ... generic registers:      6
[    0.243061] ... value mask:             0000ffffffffffff
[    0.243299] ... max period:             00007fffffffffff
[    0.244299] ... fixed-purpose events:   0
[    0.245056] ... event mask:             000000000000003f
[    0.245369] signal: max sigframe size: 3376
[    0.246172] rcu: Hierarchical SRCU implementation.
[    0.246299] rcu: 	Max phase no-delay instances is 400.
[    0.247393] smp: Bringing up secondary CPUs ...
[    0.248328] x86: Booting SMP configuration:
[    0.249125] .... node  #0, CPUs:      #1 #2 #3
[    0.250392] smp: Brought up 1 node, 4 CPUs
[    0.252087] smpboot: Max logical packages: 4
[    0.252300] smpboot: Total of 4 processors activated (26350.56 BogoMIPS)
[    0.253649] devtmpfs: initialized
[    0.254535] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1911260446275000 ns
[    0.255302] futex hash table entries: 1024 (order: 4, 65536 bytes, linear)
[    0.256324] pinctrl core: initialized pinctrl subsystem
[    0.257433] PM: RTC time: 18:59:42, date: 2026-01-22
[    0.258546] NET: Registered PF_NETLINK/PF_ROUTE protocol family
[    0.259351] audit: initializing netlink subsys (disabled)
[    0.260327] audit: type=2000 audit(1769108382.787:1): state=initialized audit_enabled=0 res=1
[    0.260351] thermal_sys: Registered thermal governor 'step_wise'
[    0.261300] thermal_sys: Registered thermal governor 'user_space'
[    0.262320] cpuidle: using governor menu
[    0.265115] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.265420] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xb0000000-0xbfffffff] (base 0xb0000000)
[    0.266301] PCI: MMCONFIG at [mem 0xb0000000-0xbfffffff] reserved in E820
[    0.267307] PCI: Using configuration type 1 for base access
[    0.269663] kprobes: kprobe jump-optimization is enabled. All kprobes are optimized if possible.
[    0.297335] HugeTLB: registered 2.00 MiB page size, pre-allocated 0 pages
[    0.298300] HugeTLB: 28 KiB vmemmap can be freed for a 2.00 MiB page
[    0.300500] ACPI: Added _OSI(Module Device)
[    0.301127] ACPI: Added _OSI(Processor Device)
[    0.301301] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.302200] ACPI: Added _OSI(Processor Aggregator Device)
[    0.303945] ACPI: 1 ACPI AML tables successfully acquired and loaded
[    0.326532] ACPI: Interpreter enabled
[    0.327306] ACPI: PM: (supports S0 S5)
[    0.328081] ACPI: Using IOAPIC for interrupt routing
[    0.329316] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.330300] PCI: Using E820 reservations for host bridge windows
[    0.331375] ACPI: Enabled 2 GPEs in block 00 to 3F
[    0.335025] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.335303] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI HPX-Type3]
[    0.337342] acpi PNP0A08:00: _OSC: platform does not support [LTR]
[    0.338338] acpi PNP0A08:00: _OSC: OS now controls [PME AER PCIeCapability]
[    0.340676] PCI host bridge to bus 0000:00
[    0.341300] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.342300] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    0.344300] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[    0.345300] pci_bus 0000:00: root bus resource [mem 0x80000000-0xafffffff window]
[    0.347301] pci_bus 0000:00: root bus resource [mem 0xc0000000-0xfebfffff window]
[    0.348300] pci_bus 0000:00: root bus resource [mem 0xc000000000-0xc7ffffffff window]
[    0.349301] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.350378] pci 0000:00:00.0: [8086:29c0] type 00 class 0x060000
[    0.353007] pci 0000:00:01.0: [1234:1111] type 00 class 0x030000
[    0.358306] pci 0000:00:01.0: reg 0x10: [mem 0xfb000000-0xfbffffff pref]
[    0.369306] pci 0000:00:01.0: reg 0x18: [mem 0xfea10000-0xfea10fff]
[    0.385310] pci 0000:00:01.0: reg 0x30: [mem 0xfea00000-0xfea0ffff pref]
[    0.386391] pci 0000:00:01.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
[    0.388608] pci 0000:00:02.0: [1b36:000c] type 01 class 0x060400
[    0.392302] pci 0000:00:02.0: reg 0x10: [mem 0xfea11000-0xfea11fff]
[    0.399438] pci 0000:00:02.0: enabling Extended Tags
[    0.401460] pci 0000:00:02.1: [1b36:000c] type 01 class 0x060400
[    0.406301] pci 0000:00:02.1: reg 0x10: [mem 0xfea12000-0xfea12fff]
[    0.412438] pci 0000:00:02.1: enabling Extended Tags
[    0.414466] pci 0000:00:02.2: [1b36:000c] type 01 class 0x060400
[    0.419068] pci 0000:00:02.2: reg 0x10: [mem 0xfea13000-0xfea13fff]
[    0.427396] pci 0000:00:02.2: enabling Extended Tags
[    0.429460] pci 0000:00:02.3: [1b36:000c] type 01 class 0x060400
[    0.433083] pci 0000:00:02.3: reg 0x10: [mem 0xfea14000-0xfea14fff]
[    0.439430] pci 0000:00:02.3: enabling Extended Tags
[    0.441452] pci 0000:00:02.4: [1b36:000c] type 01 class 0x060400
[    0.445000] pci 0000:00:02.4: reg 0x10: [mem 0xfea15000-0xfea15fff]
[    0.452154] pci 0000:00:02.4: enabling Extended Tags
[    0.453453] pci 0000:00:02.5: [1b36:000c] type 01 class 0x060400
[    0.456985] pci 0000:00:02.5: reg 0x10: [mem 0xfea16000-0xfea16fff]
[    0.463432] pci 0000:00:02.5: enabling Extended Tags
[    0.465453] pci 0000:00:02.6: [1b36:000c] type 01 class 0x060400
[    0.469120] pci 0000:00:02.6: reg 0x10: [mem 0xfea17000-0xfea17fff]
[    0.477786] pci 0000:00:02.6: enabling Extended Tags
[    0.480451] pci 0000:00:02.7: [1b36:000c] type 01 class 0x060400
[    0.484010] pci 0000:00:02.7: reg 0x10: [mem 0xfea18000-0xfea18fff]
[    0.489150] pci 0000:00:02.7: enabling Extended Tags
[    0.491459] pci 0000:00:03.0: [1b36:000c] type 01 class 0x060400
[    0.495129] pci 0000:00:03.0: reg 0x10: [mem 0xfea19000-0xfea19fff]
[    0.501151] pci 0000:00:03.0: enabling Extended Tags
[    0.503462] pci 0000:00:03.1: [1b36:000c] type 01 class 0x060400
[    0.505988] pci 0000:00:03.1: reg 0x10: [mem 0xfea1a000-0xfea1afff]
[    0.511781] pci 0000:00:03.1: enabling Extended Tags
[    0.514459] pci 0000:00:03.2: [1b36:000c] type 01 class 0x060400
[    0.517020] pci 0000:00:03.2: reg 0x10: [mem 0xfea1b000-0xfea1bfff]
[    0.524151] pci 0000:00:03.2: enabling Extended Tags
[    0.526457] pci 0000:00:03.3: [1b36:000c] type 01 class 0x060400
[    0.530000] pci 0000:00:03.3: reg 0x10: [mem 0xfea1c000-0xfea1cfff]
[    0.536151] pci 0000:00:03.3: enabling Extended Tags
[    0.538454] pci 0000:00:03.4: [1b36:000c] type 01 class 0x060400
[    0.541040] pci 0000:00:03.4: reg 0x10: [mem 0xfea1d000-0xfea1dfff]
[    0.548163] pci 0000:00:03.4: enabling Extended Tags
[    0.550479] pci 0000:00:03.5: [1b36:000c] type 01 class 0x060400
[    0.552994] pci 0000:00:03.5: reg 0x10: [mem 0xfea1e000-0xfea1efff]
[    0.559149] pci 0000:00:03.5: enabling Extended Tags
[    0.561801] pci 0000:00:1f.0: [8086:2918] type 00 class 0x060100
[    0.564084] pci 0000:00:1f.0: quirk: [io  0x0600-0x067f] claimed by ICH6 ACPI/GPIO/TCO
[    0.565672] pci 0000:00:1f.2: [8086:2922] type 00 class 0x010601
[    0.576302] pci 0000:00:1f.2: reg 0x20: [io  0xc040-0xc05f]
[    0.580301] pci 0000:00:1f.2: reg 0x24: [mem 0xfea1f000-0xfea1ffff]
[    0.582898] pci 0000:00:1f.3: [8086:2930] type 00 class 0x0c0500
[    0.588716] pci 0000:00:1f.3: reg 0x20: [io  0x0700-0x073f]
[    0.594561] acpiphp: Slot [0] registered
[    0.595556] pci 0000:01:00.0: [1af4:1041] type 00 class 0x020000
[    0.599301] pci 0000:01:00.0: reg 0x14: [mem 0xfe840000-0xfe840fff]
[    0.605301] pci 0000:01:00.0: reg 0x20: [mem 0xc1a0000000-0xc1a0003fff 64bit pref]
[    0.608301] pci 0000:01:00.0: reg 0x30: [mem 0xfe800000-0xfe83ffff pref]
[    0.609379] pci 0000:01:00.0: enabling Extended Tags
[    0.613765] pci 0000:00:02.0: PCI bridge to [bus 01]
[    0.614352] pci 0000:00:02.0:   bridge window [mem 0xfe800000-0xfe9fffff]
[    0.616353] pci 0000:00:02.0:   bridge window [mem 0xc1a0000000-0xc1bfffffff 64bit pref]
[    0.618289] acpiphp: Slot [0-1] registered
[    0.619542] pci 0000:02:00.0: [1af4:1041] type 00 class 0x020000
[    0.623301] pci 0000:02:00.0: reg 0x14: [mem 0xfe640000-0xfe640fff]
[    0.629301] pci 0000:02:00.0: reg 0x20: [mem 0xc180000000-0xc180003fff 64bit pref]
[    0.632300] pci 0000:02:00.0: reg 0x30: [mem 0xfe600000-0xfe63ffff pref]
[    0.633377] pci 0000:02:00.0: enabling Extended Tags
[    0.637369] pci 0000:00:02.1: PCI bridge to [bus 02]
[    0.638352] pci 0000:00:02.1:   bridge window [mem 0xfe600000-0xfe7fffff]
[    0.640355] pci 0000:00:02.1:   bridge window [mem 0xc180000000-0xc19fffffff 64bit pref]
[    0.642315] acpiphp: Slot [0-2] registered
[    0.643352] pci 0000:03:00.0: [1af4:1041] type 00 class 0x020000
[    0.647960] pci 0000:03:00.0: reg 0x14: [mem 0xfe440000-0xfe440fff]
[    0.653301] pci 0000:03:00.0: reg 0x20: [mem 0xc160000000-0xc160003fff 64bit pref]
[    0.659005] pci 0000:03:00.0: reg 0x30: [mem 0xfe400000-0xfe43ffff pref]
[    0.660379] pci 0000:03:00.0: enabling Extended Tags
[    0.663400] pci 0000:00:02.2: PCI bridge to [bus 03]
[    0.664348] pci 0000:00:02.2:   bridge window [mem 0xfe400000-0xfe5fffff]
[    0.665353] pci 0000:00:02.2:   bridge window [mem 0xc160000000-0xc17fffffff 64bit pref]
[    0.668283] acpiphp: Slot [0-3] registered
[    0.669551] pci 0000:04:00.0: [1af4:1048] type 00 class 0x010000
[    0.673300] pci 0000:04:00.0: reg 0x14: [mem 0xfe200000-0xfe200fff]
[    0.678301] pci 0000:04:00.0: reg 0x20: [mem 0xc140000000-0xc140003fff 64bit pref]
[    0.683385] pci 0000:04:00.0: enabling Extended Tags
[    0.686372] pci 0000:00:02.3: PCI bridge to [bus 04]
[    0.687352] pci 0000:00:02.3:   bridge window [mem 0xfe200000-0xfe3fffff]
[    0.688353] pci 0000:00:02.3:   bridge window [mem 0xc140000000-0xc15fffffff 64bit pref]
[    0.691550] acpiphp: Slot [0-4] registered
[    0.692550] pci 0000:05:00.0: [1af4:1043] type 00 class 0x078000
[    0.696300] pci 0000:05:00.0: reg 0x14: [mem 0xfe000000-0xfe000fff]
[    0.704300] pci 0000:05:00.0: reg 0x20: [mem 0xc120000000-0xc120003fff 64bit pref]
[    0.706413] pci 0000:05:00.0: enabling Extended Tags
[    0.710345] pci 0000:00:02.4: PCI bridge to [bus 05]
[    0.711352] pci 0000:00:02.4:   bridge window [mem 0xfe000000-0xfe1fffff]
[    0.712354] pci 0000:00:02.4:   bridge window [mem 0xc120000000-0xc13fffffff 64bit pref]
[    0.715273] acpiphp: Slot [0-5] registered
[    0.716473] pci 0000:06:00.0: [1b36:000d] type 00 class 0x0c0330
[    0.718093] pci 0000:06:00.0: reg 0x10: [mem 0xfde00000-0xfde03fff 64bit]
[    0.722737] pci 0000:06:00.0: enabling Extended Tags
[    0.725738] pci 0000:00:02.5: PCI bridge to [bus 06]
[    0.727351] pci 0000:00:02.5:   bridge window [mem 0xfde00000-0xfdffffff]
[    0.728351] pci 0000:00:02.5:   bridge window [mem 0xc100000000-0xc11fffffff 64bit pref]
[    0.731306] acpiphp: Slot [0-6] registered
[    0.732332] pci 0000:07:00.0: [1af4:1042] type 00 class 0x010000
[    0.737300] pci 0000:07:00.0: reg 0x14: [mem 0xfdc00000-0xfdc00fff]
[    0.746303] pci 0000:07:00.0: reg 0x20: [mem 0xc0e0000000-0xc0e0003fff 64bit pref]
[    0.753328] pci 0000:07:00.0: enabling Extended Tags
[    0.756454] pci 0000:00:02.6: PCI bridge to [bus 07]
[    0.757353] pci 0000:00:02.6:   bridge window [mem 0xfdc00000-0xfddfffff]
[    0.759362] pci 0000:00:02.6:   bridge window [mem 0xc0e0000000-0xc0ffffffff 64bit pref]
[    0.761281] acpiphp: Slot [0-7] registered
[    0.762550] pci 0000:08:00.0: [1af4:1045] type 00 class 0x00ff00
[    0.766301] pci 0000:08:00.0: reg 0x14: [mem 0xfda00000-0xfda00fff]
[    0.773014] pci 0000:08:00.0: reg 0x20: [mem 0xc0c0000000-0xc0c0003fff 64bit pref]
[    0.775384] pci 0000:08:00.0: enabling Extended Tags
[    0.778358] pci 0000:00:02.7: PCI bridge to [bus 08]
[    0.780353] pci 0000:00:02.7:   bridge window [mem 0xfda00000-0xfdbfffff]
[    0.782351] pci 0000:00:02.7:   bridge window [mem 0xc0c0000000-0xc0dfffffff 64bit pref]
[    0.784289] acpiphp: Slot [0-8] registered
[    0.785550] pci 0000:09:00.0: [1af4:1044] type 00 class 0x00ff00
[    0.789300] pci 0000:09:00.0: reg 0x14: [mem 0xfd800000-0xfd800fff]
[    0.795300] pci 0000:09:00.0: reg 0x20: [mem 0xc0a0000000-0xc0a0003fff 64bit pref]
[    0.798387] pci 0000:09:00.0: enabling Extended Tags
[    0.802442] pci 0000:00:03.0: PCI bridge to [bus 09]
[    0.803354] pci 0000:00:03.0:   bridge window [mem 0xfd800000-0xfd9fffff]
[    0.804353] pci 0000:00:03.0:   bridge window [mem 0xc0a0000000-0xc0bfffffff 64bit pref]
[    0.807370] acpiphp: Slot [0-9] registered
[    0.808180] pci 0000:00:03.1: PCI bridge to [bus 0a]
[    0.809349] pci 0000:00:03.1:   bridge window [mem 0xfd600000-0xfd7fffff]
[    0.810353] pci 0000:00:03.1:   bridge window [mem 0xc080000000-0xc09fffffff 64bit pref]
[    0.813571] acpiphp: Slot [0-10] registered
[    0.814327] pci 0000:00:03.2: PCI bridge to [bus 0b]
[    0.815337] pci 0000:00:03.2:   bridge window [mem 0xfd400000-0xfd5fffff]
[    0.816353] pci 0000:00:03.2:   bridge window [mem 0xc060000000-0xc07fffffff 64bit pref]
[    0.819258] acpiphp: Slot [0-11] registered
[    0.820335] pci 0000:00:03.3: PCI bridge to [bus 0c]
[    0.821336] pci 0000:00:03.3:   bridge window [mem 0xfd200000-0xfd3fffff]
[    0.822353] pci 0000:00:03.3:   bridge window [mem 0xc040000000-0xc05fffffff 64bit pref]
[    0.825261] acpiphp: Slot [0-12] registered
[    0.826327] pci 0000:00:03.4: PCI bridge to [bus 0d]
[    0.827340] pci 0000:00:03.4:   bridge window [mem 0xfd000000-0xfd1fffff]
[    0.828353] pci 0000:00:03.4:   bridge window [mem 0xc020000000-0xc03fffffff 64bit pref]
[    0.831244] acpiphp: Slot [0-13] registered
[    0.831329] pci 0000:00:03.5: PCI bridge to [bus 0e]
[    0.832353] pci 0000:00:03.5:   bridge window [mem 0xfce00000-0xfcffffff]
[    0.834350] pci 0000:00:03.5:   bridge window [mem 0xc000000000-0xc01fffffff 64bit pref]
[    0.849495] ACPI: PCI: Interrupt link LNKA configured for IRQ 10
[    0.850405] ACPI: PCI: Interrupt link LNKB configured for IRQ 10
[    0.851394] ACPI: PCI: Interrupt link LNKC configured for IRQ 11
[    0.853394] ACPI: PCI: Interrupt link LNKD configured for IRQ 11
[    0.854392] ACPI: PCI: Interrupt link LNKE configured for IRQ 10
[    0.855393] ACPI: PCI: Interrupt link LNKF configured for IRQ 10
[    0.857391] ACPI: PCI: Interrupt link LNKG configured for IRQ 11
[    0.858408] ACPI: PCI: Interrupt link LNKH configured for IRQ 11
[    0.859344] ACPI: PCI: Interrupt link GSIA configured for IRQ 16
[    0.861310] ACPI: PCI: Interrupt link GSIB configured for IRQ 17
[    0.862307] ACPI: PCI: Interrupt link GSIC configured for IRQ 18
[    0.863307] ACPI: PCI: Interrupt link GSID configured for IRQ 19
[    0.864307] ACPI: PCI: Interrupt link GSIE configured for IRQ 20
[    0.865307] ACPI: PCI: Interrupt link GSIF configured for IRQ 21
[    0.866308] ACPI: PCI: Interrupt link GSIG configured for IRQ 22
[    0.867307] ACPI: PCI: Interrupt link GSIH configured for IRQ 23
[    0.869555] iommu: Default domain type: Translated 
[    0.870299] iommu: DMA domain TLB invalidation policy: lazy mode 
[    0.871351] SCSI subsystem initialized
[    0.872327] ACPI: bus type USB registered
[    0.873313] usbcore: registered new interface driver usbfs
[    0.874307] usbcore: registered new interface driver hub
[    0.875307] usbcore: registered new device driver usb
[    0.876301] pps_core: LinuxPPS API ver. 1 registered
[    0.877240] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    0.878303] PTP clock support registered
[    0.879305] EDAC MC: Ver: 3.0.0
[    0.881329] Advanced Linux Sound Architecture Driver Initialized.
[    0.882461] NetLabel: Initializing
[    0.883142] NetLabel:  domain hash size = 128
[    0.884300] NetLabel:  protocols = UNLABELED CIPSOv4 CALIPSO
[    0.885310] NetLabel:  unlabeled traffic allowed by default
[    0.886317] mctp: management component transport protocol core
[    0.887300] NET: Registered PF_MCTP protocol family
[    0.888249] PCI: Using ACPI for IRQ routing
[    0.995759] pci 0000:00:01.0: vgaarb: setting as boot VGA device
[    0.996296] pci 0000:00:01.0: vgaarb: bridge control possible
[    0.996296] pci 0000:00:01.0: vgaarb: VGA device added: decodes=io+mem,owns=io+mem,locks=none
[    0.999303] vgaarb: loaded
[    1.000299] clocksource: Switched to clocksource kvm-clock
[    1.001465] VFS: Disk quotas dquot_6.6.0
[    1.002226] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.003571] pnp: PnP ACPI init
[    1.004267] system 00:04: [mem 0xb0000000-0xbfffffff window] has been reserved
[    1.005870] pnp: PnP ACPI: found 5 devices
[    1.014010] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
[    1.015719] NET: Registered PF_INET protocol family
[    1.016954] IP idents hash table entries: 262144 (order: 9, 2097152 bytes, linear)
[    1.020084] tcp_listen_portaddr_hash hash table entries: 8192 (order: 5, 131072 bytes, linear)
[    1.021743] Table-perturb hash table entries: 65536 (order: 6, 262144 bytes, linear)
[    1.023206] TCP established hash table entries: 131072 (order: 8, 1048576 bytes, linear)
[    1.024931] TCP bind hash table entries: 65536 (order: 9, 2097152 bytes, linear)
[    1.026561] TCP: Hash tables configured (established 131072 bind 65536)
[    1.027839] UDP hash table entries: 8192 (order: 6, 262144 bytes, linear)
[    1.029141] UDP-Lite hash table entries: 8192 (order: 6, 262144 bytes, linear)
[    1.030564] NET: Registered PF_UNIX/PF_LOCAL protocol family
[    1.031766] RPC: Registered named UNIX socket transport module.
[    1.032899] RPC: Registered udp transport module.
[    1.033812] RPC: Registered tcp transport module.
[    1.034710] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    1.036134] pci 0000:00:02.0: bridge window [io  0x1000-0x0fff] to [bus 01] add_size 1000
[    1.037698] pci 0000:00:02.1: bridge window [io  0x1000-0x0fff] to [bus 02] add_size 1000
[    1.039256] pci 0000:00:02.2: bridge window [io  0x1000-0x0fff] to [bus 03] add_size 1000
[    1.040814] pci 0000:00:02.3: bridge window [io  0x1000-0x0fff] to [bus 04] add_size 1000
[    1.042373] pci 0000:00:02.4: bridge window [io  0x1000-0x0fff] to [bus 05] add_size 1000
[    1.043924] pci 0000:00:02.5: bridge window [io  0x1000-0x0fff] to [bus 06] add_size 1000
[    1.045480] pci 0000:00:02.6: bridge window [io  0x1000-0x0fff] to [bus 07] add_size 1000
[    1.047033] pci 0000:00:02.7: bridge window [io  0x1000-0x0fff] to [bus 08] add_size 1000
[    1.048596] pci 0000:00:03.0: bridge window [io  0x1000-0x0fff] to [bus 09] add_size 1000
[    1.050146] pci 0000:00:03.1: bridge window [io  0x1000-0x0fff] to [bus 0a] add_size 1000
[    1.051700] pci 0000:00:03.2: bridge window [io  0x1000-0x0fff] to [bus 0b] add_size 1000
[    1.053246] pci 0000:00:03.3: bridge window [io  0x1000-0x0fff] to [bus 0c] add_size 1000
[    1.054815] pci 0000:00:03.4: bridge window [io  0x1000-0x0fff] to [bus 0d] add_size 1000
[    1.056352] pci 0000:00:03.5: bridge window [io  0x1000-0x0fff] to [bus 0e] add_size 1000
[    1.057919] pci 0000:00:02.0: BAR 13: assigned [io  0x1000-0x1fff]
[    1.059112] pci 0000:00:02.1: BAR 13: assigned [io  0x2000-0x2fff]
[    1.060285] pci 0000:00:02.2: BAR 13: assigned [io  0x3000-0x3fff]
[    1.061466] pci 0000:00:02.3: BAR 13: assigned [io  0x4000-0x4fff]
[    1.062770] pci 0000:00:02.4: BAR 13: assigned [io  0x5000-0x5fff]
[    1.063948] pci 0000:00:02.5: BAR 13: assigned [io  0x6000-0x6fff]
[    1.065124] pci 0000:00:02.6: BAR 13: assigned [io  0x7000-0x7fff]
[    1.066295] pci 0000:00:02.7: BAR 13: assigned [io  0x8000-0x8fff]
[    1.067470] pci 0000:00:03.0: BAR 13: assigned [io  0x9000-0x9fff]
[    1.068654] pci 0000:00:03.1: BAR 13: assigned [io  0xa000-0xafff]
[    1.069833] pci 0000:00:03.2: BAR 13: assigned [io  0xb000-0xbfff]
[    1.071040] pci 0000:00:03.3: BAR 13: assigned [io  0xd000-0xdfff]
[    1.072244] pci 0000:00:03.4: BAR 13: assigned [io  0xe000-0xefff]
[    1.073436] pci 0000:00:03.5: BAR 13: assigned [io  0xf000-0xffff]
[    1.074636] pci 0000:00:02.0: PCI bridge to [bus 01]
[    1.075616] pci 0000:00:02.0:   bridge window [io  0x1000-0x1fff]
[    1.079452] pci 0000:00:02.0:   bridge window [mem 0xfe800000-0xfe9fffff]
[    1.082248] pci 0000:00:02.0:   bridge window [mem 0xc1a0000000-0xc1bfffffff 64bit pref]
[    1.086847] pci 0000:00:02.1: PCI bridge to [bus 02]
[    1.088619] pci 0000:00:02.1:   bridge window [io  0x2000-0x2fff]
[    1.090865] pci 0000:00:02.1:   bridge window [mem 0xfe600000-0xfe7fffff]
[    1.092971] pci 0000:00:02.1:   bridge window [mem 0xc180000000-0xc19fffffff 64bit pref]
[    1.096809] pci 0000:00:02.2: PCI bridge to [bus 03]
[    1.097793] pci 0000:00:02.2:   bridge window [io  0x3000-0x3fff]
[    1.100877] pci 0000:00:02.2:   bridge window [mem 0xfe400000-0xfe5fffff]
[    1.102929] pci 0000:00:02.2:   bridge window [mem 0xc160000000-0xc17fffffff 64bit pref]
[    1.106164] pci 0000:00:02.3: PCI bridge to [bus 04]
[    1.107132] pci 0000:00:02.3:   bridge window [io  0x4000-0x4fff]
[    1.110923] pci 0000:00:02.3:   bridge window [mem 0xfe200000-0xfe3fffff]
[    1.113200] pci 0000:00:02.3:   bridge window [mem 0xc140000000-0xc15fffffff 64bit pref]
[    1.116091] pci 0000:00:02.4: PCI bridge to [bus 05]
[    1.117208] pci 0000:00:02.4:   bridge window [io  0x5000-0x5fff]
[    1.119498] pci 0000:00:02.4:   bridge window [mem 0xfe000000-0xfe1fffff]
[    1.122332] pci 0000:00:02.4:   bridge window [mem 0xc120000000-0xc13fffffff 64bit pref]
[    1.125534] pci 0000:00:02.5: PCI bridge to [bus 06]
[    1.126503] pci 0000:00:02.5:   bridge window [io  0x6000-0x6fff]
[    1.128735] pci 0000:00:02.5:   bridge window [mem 0xfde00000-0xfdffffff]
[    1.130791] pci 0000:00:02.5:   bridge window [mem 0xc100000000-0xc11fffffff 64bit pref]
[    1.134665] pci 0000:00:02.6: PCI bridge to [bus 07]
[    1.135649] pci 0000:00:02.6:   bridge window [io  0x7000-0x7fff]
[    1.137843] pci 0000:00:02.6:   bridge window [mem 0xfdc00000-0xfddfffff]
[    1.143254] pci 0000:00:02.6:   bridge window [mem 0xc0e0000000-0xc0ffffffff 64bit pref]
[    1.147166] pci 0000:00:02.7: PCI bridge to [bus 08]
[    1.148147] pci 0000:00:02.7:   bridge window [io  0x8000-0x8fff]
[    1.150372] pci 0000:00:02.7:   bridge window [mem 0xfda00000-0xfdbfffff]
[    1.152572] pci 0000:00:02.7:   bridge window [mem 0xc0c0000000-0xc0dfffffff 64bit pref]
[    1.157027] pci 0000:00:03.0: PCI bridge to [bus 09]
[    1.157999] pci 0000:00:03.0:   bridge window [io  0x9000-0x9fff]
[    1.160194] pci 0000:00:03.0:   bridge window [mem 0xfd800000-0xfd9fffff]
[    1.162164] pci 0000:00:03.0:   bridge window [mem 0xc0a0000000-0xc0bfffffff 64bit pref]
[    1.165174] pci 0000:00:03.1: PCI bridge to [bus 0a]
[    1.166149] pci 0000:00:03.1:   bridge window [io  0xa000-0xafff]
[    1.169032] pci 0000:00:03.1:   bridge window [mem 0xfd600000-0xfd7fffff]
[    1.171057] pci 0000:00:03.1:   bridge window [mem 0xc080000000-0xc09fffffff 64bit pref]
[    1.174148] pci 0000:00:03.2: PCI bridge to [bus 0b]
[    1.175148] pci 0000:00:03.2:   bridge window [io  0xb000-0xbfff]
[    1.178583] pci 0000:00:03.2:   bridge window [mem 0xfd400000-0xfd5fffff]
[    1.180826] pci 0000:00:03.2:   bridge window [mem 0xc060000000-0xc07fffffff 64bit pref]
[    1.183687] pci 0000:00:03.3: PCI bridge to [bus 0c]
[    1.184667] pci 0000:00:03.3:   bridge window [io  0xd000-0xdfff]
[    1.186876] pci 0000:00:03.3:   bridge window [mem 0xfd200000-0xfd3fffff]
[    1.189067] pci 0000:00:03.3:   bridge window [mem 0xc040000000-0xc05fffffff 64bit pref]
[    1.192901] pci 0000:00:03.4: PCI bridge to [bus 0d]
[    1.193881] pci 0000:00:03.4:   bridge window [io  0xe000-0xefff]
[    1.196005] pci 0000:00:03.4:   bridge window [mem 0xfd000000-0xfd1fffff]
[    1.197976] pci 0000:00:03.4:   bridge window [mem 0xc020000000-0xc03fffffff 64bit pref]
[    1.201761] pci 0000:00:03.5: PCI bridge to [bus 0e]
[    1.202731] pci 0000:00:03.5:   bridge window [io  0xf000-0xffff]
[    1.204877] pci 0000:00:03.5:   bridge window [mem 0xfce00000-0xfcffffff]
[    1.206833] pci 0000:00:03.5:   bridge window [mem 0xc000000000-0xc01fffffff 64bit pref]
[    1.209743] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
[    1.210927] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff window]
[    1.212745] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff window]
[    1.214077] pci_bus 0000:00: resource 7 [mem 0x80000000-0xafffffff window]
[    1.215407] pci_bus 0000:00: resource 8 [mem 0xc0000000-0xfebfffff window]
[    1.216715] pci_bus 0000:00: resource 9 [mem 0xc000000000-0xc7ffffffff window]
[    1.218094] pci_bus 0000:01: resource 0 [io  0x1000-0x1fff]
[    1.219165] pci_bus 0000:01: resource 1 [mem 0xfe800000-0xfe9fffff]
[    1.220382] pci_bus 0000:01: resource 2 [mem 0xc1a0000000-0xc1bfffffff 64bit pref]
[    1.221815] pci_bus 0000:02: resource 0 [io  0x2000-0x2fff]
[    1.222892] pci_bus 0000:02: resource 1 [mem 0xfe600000-0xfe7fffff]
[    1.224089] pci_bus 0000:02: resource 2 [mem 0xc180000000-0xc19fffffff 64bit pref]
[    1.225536] pci_bus 0000:03: resource 0 [io  0x3000-0x3fff]
[    1.226726] pci_bus 0000:03: resource 1 [mem 0xfe400000-0xfe5fffff]
[    1.227918] pci_bus 0000:03: resource 2 [mem 0xc160000000-0xc17fffffff 64bit pref]
[    1.229384] pci_bus 0000:04: resource 0 [io  0x4000-0x4fff]
[    1.230457] pci_bus 0000:04: resource 1 [mem 0xfe200000-0xfe3fffff]
[    1.231669] pci_bus 0000:04: resource 2 [mem 0xc140000000-0xc15fffffff 64bit pref]
[    1.233103] pci_bus 0000:05: resource 0 [io  0x5000-0x5fff]
[    1.234170] pci_bus 0000:05: resource 1 [mem 0xfe000000-0xfe1fffff]
[    1.235388] pci_bus 0000:05: resource 2 [mem 0xc120000000-0xc13fffffff 64bit pref]
[    1.236841] pci_bus 0000:06: resource 0 [io  0x6000-0x6fff]
[    1.237902] pci_bus 0000:06: resource 1 [mem 0xfde00000-0xfdffffff]
[    1.239101] pci_bus 0000:06: resource 2 [mem 0xc100000000-0xc11fffffff 64bit pref]
[    1.240533] pci_bus 0000:07: resource 0 [io  0x7000-0x7fff]
[    1.241592] pci_bus 0000:07: resource 1 [mem 0xfdc00000-0xfddfffff]
[    1.242781] pci_bus 0000:07: resource 2 [mem 0xc0e0000000-0xc0ffffffff 64bit pref]
[    1.244225] pci_bus 0000:08: resource 0 [io  0x8000-0x8fff]
[    1.245311] pci_bus 0000:08: resource 1 [mem 0xfda00000-0xfdbfffff]
[    1.246497] pci_bus 0000:08: resource 2 [mem 0xc0c0000000-0xc0dfffffff 64bit pref]
[    1.247913] pci_bus 0000:09: resource 0 [io  0x9000-0x9fff]
[    1.248973] pci_bus 0000:09: resource 1 [mem 0xfd800000-0xfd9fffff]
[    1.250181] pci_bus 0000:09: resource 2 [mem 0xc0a0000000-0xc0bfffffff 64bit pref]
[    1.251615] pci_bus 0000:0a: resource 0 [io  0xa000-0xafff]
[    1.252681] pci_bus 0000:0a: resource 1 [mem 0xfd600000-0xfd7fffff]
[    1.253873] pci_bus 0000:0a: resource 2 [mem 0xc080000000-0xc09fffffff 64bit pref]
[    1.255313] pci_bus 0000:0b: resource 0 [io  0xb000-0xbfff]
[    1.256368] pci_bus 0000:0b: resource 1 [mem 0xfd400000-0xfd5fffff]
[    1.257553] pci_bus 0000:0b: resource 2 [mem 0xc060000000-0xc07fffffff 64bit pref]
[    1.258975] pci_bus 0000:0c: resource 0 [io  0xd000-0xdfff]
[    1.260038] pci_bus 0000:0c: resource 1 [mem 0xfd200000-0xfd3fffff]
[    1.261255] pci_bus 0000:0c: resource 2 [mem 0xc040000000-0xc05fffffff 64bit pref]
[    1.263050] pci_bus 0000:0d: resource 0 [io  0xe000-0xefff]
[    1.264126] pci_bus 0000:0d: resource 1 [mem 0xfd000000-0xfd1fffff]
[    1.265321] pci_bus 0000:0d: resource 2 [mem 0xc020000000-0xc03fffffff 64bit pref]
[    1.266759] pci_bus 0000:0e: resource 0 [io  0xf000-0xffff]
[    1.267827] pci_bus 0000:0e: resource 1 [mem 0xfce00000-0xfcffffff]
[    1.269041] pci_bus 0000:0e: resource 2 [mem 0xc000000000-0xc01fffffff 64bit pref]
[    1.270999] ACPI: \_SB_.GSIG: Enabled at IRQ 22
[    1.273466] PCI: CLS 0 bytes, default 64
[    1.274267] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    1.274322] Unpacking initramfs...
[    1.275506] software IO TLB: mapped [mem 0x000000006f000000-0x0000000077000000] (128MB)
[    1.279215] Initialise system trusted keyrings
[    1.280132] workingset: timestamp_bits=40 max_order=22 bucket_order=0
[    1.282455] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[    1.283995] NFS: Registering the id_resolver key type
[    1.285075] Key type id_resolver registered
[    1.285940] Key type id_legacy registered
[    1.289480] Key type asymmetric registered
[    1.290291] Asymmetric key parser 'x509' registered
[    1.291293] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 248)
[    1.292797] io scheduler mq-deadline registered
[    1.293724] io scheduler kyber registered
[    1.296746] pcieport 0000:00:02.0: PME: Signaling with IRQ 25
[    1.298115] pcieport 0000:00:02.0: AER: enabled with IRQ 25
[    1.302307] pcieport 0000:00:02.1: PME: Signaling with IRQ 26
[    1.304379] pcieport 0000:00:02.1: AER: enabled with IRQ 26
[    1.308318] pcieport 0000:00:02.2: PME: Signaling with IRQ 27
[    1.309969] pcieport 0000:00:02.2: AER: enabled with IRQ 27
[    1.315133] pcieport 0000:00:02.3: PME: Signaling with IRQ 28
[    1.316735] pcieport 0000:00:02.3: AER: enabled with IRQ 28
[    1.322519] pcieport 0000:00:02.4: PME: Signaling with IRQ 29
[    1.323909] pcieport 0000:00:02.4: AER: enabled with IRQ 29
[    1.327177] pcieport 0000:00:02.5: PME: Signaling with IRQ 30
[    1.328832] pcieport 0000:00:02.5: AER: enabled with IRQ 30
[    1.333238] pcieport 0000:00:02.6: PME: Signaling with IRQ 31
[    1.335286] pcieport 0000:00:02.6: AER: enabled with IRQ 31
[    1.339508] pcieport 0000:00:02.7: PME: Signaling with IRQ 32
[    1.341223] pcieport 0000:00:02.7: AER: enabled with IRQ 32
[    1.343096] ACPI: \_SB_.GSIH: Enabled at IRQ 23
[    1.346355] pcieport 0000:00:03.0: PME: Signaling with IRQ 33
[    1.347836] pcieport 0000:00:03.0: AER: enabled with IRQ 33
[    1.351155] Freeing initrd memory: 8960K
[    1.351971] pcieport 0000:00:03.1: PME: Signaling with IRQ 34
[    1.354080] pcieport 0000:00:03.1: AER: enabled with IRQ 34
[    1.357862] pcieport 0000:00:03.2: PME: Signaling with IRQ 35
[    1.359502] pcieport 0000:00:03.2: AER: enabled with IRQ 35
[    1.364392] pcieport 0000:00:03.3: PME: Signaling with IRQ 36
[    1.366570] pcieport 0000:00:03.3: AER: enabled with IRQ 36
[    1.370168] pcieport 0000:00:03.4: PME: Signaling with IRQ 37
[    1.371577] pcieport 0000:00:03.4: AER: enabled with IRQ 37
[    1.375610] pcieport 0000:00:03.5: PME: Signaling with IRQ 38
[    1.377711] pcieport 0000:00:03.5: AER: enabled with IRQ 38
[    1.379296] IPMI message handler: version 39.2
[    1.380305] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    1.381765] ACPI: button: Power Button [PWRF]
[    1.397762] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    1.399145] 00:00: ttyS0 at I/O 0x3f8 (irq = 4, base_baud = 115200) is a 16550A
[    1.420777] Non-volatile memory driver v1.3
[    1.424054] Linux agpgart interface v0.103
[    1.425328] random: crng init done
[    1.425346] ACPI: bus type drm_connector registered
[    1.427816] loop: module loaded
[    1.428583] virtio_blk virtio5: 4/0/0 default/read/poll queues
[    1.432847] virtio_blk virtio5: [vda] 41943040 512-byte logical blocks (21.5 GB/20.0 GiB)
[    1.448546] GPT:Primary header thinks Alt. header is not at the end of the disk.
[    1.450503] GPT:33554431 != 41943039
[    1.451345] GPT:Alternate GPT header not at the end of the disk.
[    1.452754] GPT:33554431 != 41943039
[    1.453578] GPT: Use GNU Parted to correct GPT errors.
[    1.454697]  vda: vda1 vda2
[    1.455706] ACPI: \_SB_.GSIA: Enabled at IRQ 16
[    1.457645] ahci 0000:00:1f.2: AHCI 0001.0000 32 slots 6 ports 1.5 Gbps 0x3f impl SATA mode
[    1.459262] ahci 0000:00:1f.2: flags: 64bit ncq only 
[    1.461721] scsi host0: ahci
[    1.462381] scsi host1: ahci
[    1.463034] scsi host2: ahci
[    1.463679] scsi host3: ahci
[    1.464305] scsi host4: ahci
[    1.464955] scsi host5: ahci
[    1.465576] ata1: SATA max UDMA/133 abar m4096@0xfea1f000 port 0xfea1f100 irq 48
[    1.467001] ata2: SATA max UDMA/133 abar m4096@0xfea1f000 port 0xfea1f180 irq 48
[    1.468447] ata3: SATA max UDMA/133 abar m4096@0xfea1f000 port 0xfea1f200 irq 48
[    1.469978] ata4: SATA max UDMA/133 abar m4096@0xfea1f000 port 0xfea1f280 irq 48
[    1.471512] ata5: SATA max UDMA/133 abar m4096@0xfea1f000 port 0xfea1f300 irq 48
[    1.473050] ata6: SATA max UDMA/133 abar m4096@0xfea1f000 port 0xfea1f380 irq 48
[    1.475282] tun: Universal TUN/TAP device driver, 1.6
[    1.493084] e100: Intel(R) PRO/100 Network Driver
[    1.494045] e100: Copyright(c) 1999-2006 Intel Corporation
[    1.495153] e1000: Intel(R) PRO/1000 Network Driver
[    1.496089] e1000: Copyright (c) 1999-2006 Intel Corporation.
[    1.497203] e1000e: Intel(R) PRO/1000 Network Driver
[    1.498298] e1000e: Copyright(c) 1999 - 2015 Intel Corporation.
[    1.499556] igb: Intel(R) Gigabit Ethernet Network Driver
[    1.500581] igb: Copyright (c) 2007-2014 Intel Corporation.
[    1.501637] igbvf: Intel(R) Gigabit Virtual Function Network Driver
[    1.502835] igbvf: Copyright (c) 2009 - 2012 Intel Corporation.
[    1.503968] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver
[    1.505143] ixgbe: Copyright (c) 1999-2016 Intel Corporation.
[    1.506298] ixgb: Intel(R) PRO/10GbE Network Driver
[    1.507234] ixgb: Copyright (c) 1999-2008 Intel Corporation.
[    1.508327] sky2: driver version 1.30
[    1.509121] VFIO - User Level meta-driver version: 0.3
[    1.511273] xhci_hcd 0000:06:00.0: xHCI Host Controller
[    1.512316] xhci_hcd 0000:06:00.0: new USB bus registered, assigned bus number 1
[    1.514161] xhci_hcd 0000:06:00.0: hcc params 0x00087001 hci version 0x100 quirks 0x0000000000000010
[    1.520251] xhci_hcd 0000:06:00.0: xHCI Host Controller
[    1.521372] xhci_hcd 0000:06:00.0: new USB bus registered, assigned bus number 2
[    1.522793] xhci_hcd 0000:06:00.0: Host supports USB 3.0 SuperSpeed
[    1.524069] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002, bcdDevice= 6.01
[    1.525631] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.527023] usb usb1: Product: xHCI Host Controller
[    1.527964] usb usb1: Manufacturer: Linux 6.1.55-arrcus xhci-hcd
[    1.529105] usb usb1: SerialNumber: 0000:06:00.0
[    1.530068] hub 1-0:1.0: USB hub found
[    1.530914] hub 1-0:1.0: 15 ports detected
[    1.532464] usb usb2: We don't know the algorithms for LPM for this host, disabling LPM.
[    1.534017] usb usb2: New USB device found, idVendor=1d6b, idProduct=0003, bcdDevice= 6.01
[    1.535642] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.537003] usb usb2: Product: xHCI Host Controller
[    1.537944] usb usb2: Manufacturer: Linux 6.1.55-arrcus xhci-hcd
[    1.539093] usb usb2: SerialNumber: 0000:06:00.0
[    1.540033] hub 2-0:1.0: USB hub found
[    1.540883] hub 2-0:1.0: 15 ports detected
[    1.542445] usbcore: registered new interface driver usblp
[    1.543527] usbcore: registered new interface driver usb-storage
[    1.544693] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[    1.548009] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.549024] serio: i8042 AUX port at 0x60,0x64 irq 12
[    1.550142] mousedev: PS/2 mouse device common for all mice
[    1.551353] rtc_cmos 00:03: RTC can wake from S4
[    1.552818] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input1
[    1.556830] rtc_cmos 00:03: registered as rtc0
[    1.557916] rtc_cmos 00:03: alarms up to one day, y3k, 242 bytes nvram
[    1.559290] i2c_dev: i2c /dev entries driver
[    1.560551] IR JVC protocol handler initialized
[    1.560998] i801_smbus 0000:00:1f.3: SMBus using PCI interrupt
[    1.561790] IR MCE Keyboard/mouse protocol handler initialized
[    1.564078] IR NEC protocol handler initialized
[    1.564126] i2c i2c-0: 1/1 memory slots populated (from DMI)
[    1.565030] IR RC5(x/sz) protocol handler initialized
[    1.566149] i2c i2c-0: Memory type 0x07 not supported yet, not instantiating SPD
[    1.567155] IR RC6 protocol handler initialized
[    1.569551] IR SANYO protocol handler initialized
[    1.570511] IR Sharp protocol handler initialized
[    1.571540] IR Sony protocol handler initialized
[    1.572470] IR XMP protocol handler initialized
[    1.576489] device-mapper: ioctl: 4.47.0-ioctl (2022-07-28) initialised: dm-devel@redhat.com
[    1.578324] hid: raw HID events driver (C) Jiri Kosina
[    1.579504] usbcore: registered new interface driver usbhid
[    1.580579] usbhid: USB HID core driver
[    1.581836] xt_time: kernel timezone is -0000
[    1.582726] IPVS: Registered protocols (TCP, UDP, SCTP, AH, ESP)
[    1.583907] IPVS: Connection hash table configured (size=4096, memory=32Kbytes)
[    1.585452] IPVS: ipvs loaded.
[    1.586041] IPVS: [rr] scheduler registered.
[    1.586874] IPVS: [wrr] scheduler registered.
[    1.587729] IPVS: [lc] scheduler registered.
[    1.588556] IPVS: [wlc] scheduler registered.
[    1.589383] IPVS: [fo] scheduler registered.
[    1.590197] IPVS: [ovf] scheduler registered.
[    1.591041] IPVS: [lblc] scheduler registered.
[    1.591902] IPVS: [lblcr] scheduler registered.
[    1.592770] IPVS: [dh] scheduler registered.
[    1.593592] IPVS: [sh] scheduler registered.
[    1.594399] IPVS: [sed] scheduler registered.
[    1.595224] IPVS: [nq] scheduler registered.
[    1.596042] IPVS: [sip] pe registered.
[    1.596801] ipt_CLUSTERIP: ClusterIP Version 0.8 loaded successfully
[    1.598013] Initializing XFRM netlink socket
[    1.598913] NET: Registered PF_INET6 protocol family
[    1.604471] Segment Routing with IPv6
[    1.605316] In-situ OAM (IOAM) with IPv6
[    1.606092] sit: IPv6, IPv4 and MPLS over IPv4 tunneling driver
[    1.607425] NET: Registered PF_PACKET protocol family
[    1.608389] bridge: filtering via arp/ip/ip6tables is no longer available by default. Update your scripts to load br_netfilter if you need this.
[    1.610865] NET: Registered PF_KCM protocol family
[    1.611825] 8021q: 802.1Q VLAN Support v1.8
[    1.612639] Key type dns_resolver registered
[    1.613478] mpls_gso: MPLS GSO support
[    1.614457] IPI shorthand broadcast: enabled
[    1.615329] registered taskstats version 1
[    1.616133] Loading compiled-in X.509 certificates
[    1.617701] PM:   Magic number: 10:973:999
[    1.618522] block vda: hash matches
[    1.619204] i8042 kbd 00:01: hash matches
[    1.619958]  pnp0: hash matches
[    1.620579] printk: console [netcon0] enabled
[    1.621396] netconsole: network logging started
[    1.622373] cfg80211: Loading compiled-in X.509 certificates for regulatory database
[    1.626065] cfg80211: Loaded X.509 cert 'sforshee: 00b28ddf47aef9cea7'
[    1.627531] platform regulatory.0: Direct firmware load for regulatory.db failed with error -2
[    1.629164] cfg80211: failed to load regulatory.db
[    1.630089] Unstable clock detected, switching default tracing clock to "global"
[    1.630089] If you want to keep using the local clock, then add:
[    1.630089]   "trace_clock=local"
[    1.630089] on the kernel command line
[    1.633916] ALSA device list:
[    1.634510]   No soundcards found.
[    1.772468] usb 1-1: new high-speed USB device number 2 using xhci_hcd
[    1.786848] ata6: SATA link down (SStatus 0 SControl 300)
[    1.788288] ata4: SATA link down (SStatus 0 SControl 300)
[    1.789740] ata3: SATA link down (SStatus 0 SControl 300)
[    1.791048] ata5: SATA link down (SStatus 0 SControl 300)
[    1.792388] ata2: SATA link down (SStatus 0 SControl 300)
[    1.793937] ata1: SATA link down (SStatus 0 SControl 300)
[    1.795724] Freeing unused kernel image (initmem) memory: 1880K
[    1.796987] Write protecting the kernel read-only data: 28672k
[    1.798364] Freeing unused kernel image (text/rodata gap) memory: 2032K
[    1.799559] Freeing unused kernel image (rodata/data gap) memory: 988K
[    1.800503] Run /init as init process
Loading, please wait...
Starting systemd-udevd version 252.39-1~deb12u1
[    1.851929] lpc_ich 0000:00:1f.0: I/O space for GPIO uninitialized
[    1.862190] scsi host6: Virtio SCSI HBA
[    1.902541] usb 1-1: New USB device found, idVendor=0627, idProduct=0001, bcdDevice= 0.00
[    1.904388] usb 1-1: New USB device strings: Mfr=1, Product=3, SerialNumber=10
[    1.905860] usb 1-1: Product: QEMU USB Tablet
[    1.906714] usb 1-1: Manufacturer: QEMU
[    1.907447] usb 1-1: SerialNumber: 28754-0000:00:02.5:00.0-1
[    1.909999] input: QEMU QEMU USB Tablet as /devices/pci0000:00/0000:00:02.5/0000:06:00.0/usb1/1-1/1-1:1.0/0003:0627:0001.0001/input/input4
[    1.912339] hid-generic 0003:0627:0001.0001: input,hidraw0: USB HID v0.01 Mouse [QEMU QEMU USB Tablet] on usb-0000:06:00.0-1/input0
Begin: Loading essential drivers ... done.
Begin: Running /scripts/init-premount ... done.
Begin: Mounting root file system ... Begin: Running /scripts/local-top ... done.
Begin: Running /scripts/local-premount ... done.
Begin: Will now check root file system ... fsck from util-linux 2.38.1
[/sbin/fsck.ext4 (1) -- /dev/vda2] fsck.ext4 -a -C0 /dev/vda2 
ARCOS-ROOT: clean, 35849/1048576 files, 462667/4194043 blocks
done.
[    1.965175] EXT4-fs (vda2): mounted filesystem with ordered data mode. Quota mode: none.
done.
Begin: Running /scripts/local-bottom ... done.
Begin: Running /scripts/init-bottom ... done.
[    2.039086] systemd[1]: systemd 252.39-1~deb12u1 running in system mode (+PAM +AUDIT +SELINUX +APPARMOR +IMA +SMACK +SECCOMP +GCRYPT -GNUTLS +OPENSSL +ACL +BLKID +CURL +ELFUTILS +FIDO2 +IDN2 -IDN +IPTC +KMOD +LIBCRYPTSETUP +LIBFDISK +PCRE2 -PWQUALITY +P11KIT +QRENCODE +TPM2 +BZIP2 +LZ4 +XZ +ZLIB +ZSTD -BPF_FRAMEWORK -XKBCOMMON +UTMP +SYSVINIT default-hierarchy=unified)
[    2.043217] systemd[1]: Detected virtualization kvm.
[    2.043885] systemd[1]: Detected architecture x86-64.

Welcome to [1mDebian GNU/Linux 12 (bookworm)[0m!

[    2.046309] systemd[1]: Hostname set to <localhost>.
[    2.049181] systemd[1]: Initializing machine ID from VM UUID.
[    2.049949] systemd[1]: Installed transient /etc/machine-id file.
[    2.191798] systemd[1]: Queued start job for default target graphical.target.
[    2.196119] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/i8042/serio1/input/input3
[    2.203202] systemd[1]: Created slice system-getty.slice - Slice /system/getty.
[[0;32m  OK  [0m] Created slice [0;1;39msystem-getty.slice[0m - Slice /system/getty.
[    2.205742] systemd[1]: Created slice system-modprobe.slice - Slice /system/modprobe.
[[0;32m  OK  [0m] Created slice [0;1;39msystem-modpr…lice[0m - Slice /system/modprobe.
[    2.208518] systemd[1]: Created slice system-serial\x2dgetty.slice - Slice /system/serial-getty.
[[0;32m  OK  [0m] Created slice [0;1;39msystem-seria…[0m - Slice /system/serial-getty.
[    2.211026] systemd[1]: Created slice user.slice - User and Session Slice.
[[0;32m  OK  [0m] Created slice [0;1;39muser.slice[0m - User and Session Slice.
[    2.213302] systemd[1]: Started systemd-ask-password-console.path - Dispatch Password Requests to Console Directory Watch.
[[0;32m  OK  [0m] Started [0;1;39msystemd-ask-passwo…quests to Console Directory Watch.
[    2.216005] systemd[1]: Started systemd-ask-password-wall.path - Forward Password Requests to Wall Directory Watch.
[[0;32m  OK  [0m] Started [0;1;39msystemd-ask-passwo… Requests to Wall Directory Watch.
[    2.218948] systemd[1]: Set up automount proc-sys-fs-binfmt_misc.automount - Arbitrary Executable File Formats File System Automount Point.
[[0;32m  OK  [0m] Set up automount [0;1;39mproc-sys-…rmats File System Automount Point.
[    2.222041] systemd[1]: Expecting device dev-ttyS0.device - /dev/ttyS0...
         Expecting device [0;1;39mdev-ttyS0.device[0m - /dev/ttyS0...
[    2.224281] systemd[1]: Reached target cryptsetup.target - Local Encrypted Volumes.
[[0;32m  OK  [0m] Reached target [0;1;39mcryptsetup.…get[0m - Local Encrypted Volumes.
[    2.226632] systemd[1]: Reached target integritysetup.target - Local Integrity Protected Volumes.
[[0;32m  OK  [0m] Reached target [0;1;39mintegrityse…Local Integrity Protected Volumes.
[    2.229176] systemd[1]: Reached target paths.target - Path Units.
[[0;32m  OK  [0m] Reached target [0;1;39mpaths.target[0m - Path Units.
[    2.231154] systemd[1]: Reached target remote-fs.target - Remote File Systems.
[[0;32m  OK  [0m] Reached target [0;1;39mremote-fs.target[0m - Remote File Systems.
[    2.233484] systemd[1]: Reached target slices.target - Slice Units.
[[0;32m  OK  [0m] Reached target [0;1;39mslices.target[0m - Slice Units.
[    2.235498] systemd[1]: Reached target swap.target - Swaps.
[[0;32m  OK  [0m] Reached target [0;1;39mswap.target[0m - Swaps.
[    2.237294] systemd[1]: Reached target time-set.target - System Time Set.
[[0;32m  OK  [0m] Reached target [0;1;39mtime-set.target[0m - System Time Set.
[    2.239475] systemd[1]: Reached target veritysetup.target - Local Verity Protected Volumes.
[[0;32m  OK  [0m] Reached target [0;1;39mveritysetup… - Local Verity Protected Volumes.
[    2.242010] systemd[1]: Listening on syslog.socket - Syslog Socket.
[[0;32m  OK  [0m] Listening on [0;1;39msyslog.socket[0m - Syslog Socket.
[    2.244048] systemd[1]: Listening on systemd-fsckd.socket - fsck to fsckd communication Socket.
[[0;32m  OK  [0m] Listening on [0;1;39msystemd-fsckd…sck to fsckd communication Socket.
[    2.246675] systemd[1]: Listening on systemd-initctl.socket - initctl Compatibility Named Pipe.
[[0;32m  OK  [0m] Listening on [0;1;39msystemd-initc… initctl Compatibility Named Pipe.
[    2.249355] systemd[1]: Listening on systemd-journald-audit.socket - Journal Audit Socket.
[[0;32m  OK  [0m] Listening on [0;1;39msystemd-journ…socket[0m - Journal Audit Socket.
[    2.251948] systemd[1]: Listening on systemd-journald-dev-log.socket - Journal Socket (/dev/log).
[[0;32m  OK  [0m] Listening on [0;1;39msystemd-journ…t[0m - Journal Socket (/dev/log).
[    2.254545] systemd[1]: Listening on systemd-journald.socket - Journal Socket.
[[0;32m  OK  [0m] Listening on [0;1;39msystemd-journald.socket[0m - Journal Socket.
[    2.257248] systemd[1]: Listening on systemd-udevd-control.socket - udev Control Socket.
[[0;32m  OK  [0m] Listening on [0;1;39msystemd-udevd….socket[0m - udev Control Socket.
[    2.259898] systemd[1]: Listening on systemd-udevd-kernel.socket - udev Kernel Socket.
[[0;32m  OK  [0m] Listening on [0;1;39msystemd-udevd…l.socket[0m - udev Kernel Socket.
[    2.272546] systemd[1]: Mounting dev-hugepages.mount - Huge Pages File System...
         Mounting [0;1;39mdev-hugepages.mount[0m - Huge Pages File System...
[    2.275945] systemd[1]: Mounting dev-mqueue.mount - POSIX Message Queue File System...
         Mounting [0;1;39mdev-mqueue.mount…POSIX Message Queue File System...
[    2.278657] systemd[1]: Mounting sys-kernel-debug.mount - Kernel Debug File System...
         Mounting [0;1;39msys-kernel-debug.…[0m - Kernel Debug File System...
[    2.281307] systemd[1]: Mounting sys-kernel-tracing.mount - Kernel Trace File System...
         Mounting [0;1;39msys-kernel-tracin…[0m - Kernel Trace File System...
[    2.284203] systemd[1]: Starting kmod-static-nodes.service - Create List of Static Device Nodes...
         Starting [0;1;39mkmod-static-nodes…ate List of Static Device Nodes...
[    2.287092] systemd[1]: Starting modprobe@configfs.service - Load Kernel Module configfs...
         Starting [0;1;39mmodprobe@configfs…m - Load Kernel Module configfs...
[    2.289816] systemd[1]: Starting modprobe@dm_mod.service - Load Kernel Module dm_mod...
         Starting [0;1;39mmodprobe@dm_mod.s…[0m - Load Kernel Module dm_mod...
[    2.292460] systemd[1]: Starting modprobe@drm.service - Load Kernel Module drm...
         Starting [0;1;39mmodprobe@drm.service[0m - Load Kernel Module drm...
[    2.295012] systemd[1]: Starting modprobe@efi_pstore.service - Load Kernel Module efi_pstore...
         Starting [0;1;39mmodprobe@efi_psto…- Load Kernel Module efi_pstore...
[    2.297737] systemd[1]: Starting modprobe@fuse.service - Load Kernel Module fuse...
         Starting [0;1;39mmodprobe@fuse.ser…e[0m - Load Kernel Module fuse...
[    2.300334] systemd[1]: Starting modprobe@loop.service - Load Kernel Module loop...
         Starting [0;1;39mmodprobe@loop.ser…e[0m - Load Kernel Module loop...
[    2.302614] systemd[1]: systemd-fsck-root.service - File System Check on Root Device was skipped because of an unmet condition check (ConditionPathExists=!/run/initramfs/fsck-root).
[    2.305353] systemd[1]: Starting systemd-journald.service - Journal Service...
         Starting [0;1;39msystemd-journald.service[0m - Journal Service...
[    2.308357] systemd[1]: Starting systemd-modules-load.service - Load Kernel Modules...
         Starting [0;1;39msystemd-modules-l…rvice[0m - Load Kernel Modules...
[    2.311259] systemd[1]: Starting systemd-remount-fs.service - Remount Root and Kernel File Systems...
         Starting [0;1;39msystemd-remount-f…nt Root and Kernel File Systems...
[    2.314539] systemd[1]: Starting systemd-udev-trigger.service - Coldplug All udev Devices...
         Starting [0;1;39msystemd-udev-trig…[0m - Coldplug All udev Devices...
[    2.318449] EXT4-fs (vda2): re-mounted. Quota mode: none.
[    2.318961] systemd[1]: Mounted dev-hugepages.mount - Huge Pages File System.
[[0;32m  OK  [0m] Mounted [0;1;39mdev-hugepages.mount[0m - Huge Pages File System.
[    2.322868] systemd[1]: Mounted dev-mqueue.mount - POSIX Message Queue File System.
[[0;32m  OK  [0m] Mounted [0;1;39mdev-mqueue.mount[…- POSIX Message Queue File System.
[    2.325372] systemd[1]: Mounted sys-kernel-debug.mount - Kernel Debug File System.
[[0;32m  OK  [0m] Mounted [0;1;39msys-kernel-debug.m…nt[0m - Kernel Debug File System.
[    2.327875] systemd[1]: Mounted sys-kernel-tracing.mount - Kernel Trace File System.
[[0;32m  OK  [0m] Mounted [0;1;39msys-kernel-tracing…nt[0m - Kernel Trace File System.
[    2.330557] systemd[1]: Finished kmod-static-nodes.service - Create List of Static Device Nodes.
[[0;32m  OK  [0m] Finished [0;1;39mkmod-static-nodes…reate List of Static Device Nodes.
[    2.333181] systemd[1]: modprobe@configfs.service: Deactivated successfully.
[    2.334178] systemd[1]: Finished modprobe@configfs.service - Load Kernel Module configfs.
[[0;32m  OK  [0m] Finished [0;1;39mmodprobe@configfs…[0m - Load Kernel Module configfs.
[    2.336885] systemd[1]: modprobe@dm_mod.service: Deactivated successfully.
[    2.337822] systemd[1]: Finished modprobe@dm_mod.service - Load Kernel Module dm_mod.
[[0;32m  OK  [0m] Finished [0;1;39mmodprobe@dm_mod.s…e[0m - Load Kernel Module dm_mod.
[    2.340322] systemd[1]: modprobe@drm.service: Deactivated successfully.
[    2.341232] systemd[1]: Finished modprobe@drm.service - Load Kernel Module drm.
[[0;32m  OK  [0m] Finished [0;1;39mmodprobe@drm.service[0m - Load Kernel Module drm.
[    2.343552] systemd[1]: modprobe@efi_pstore.service: Deactivated successfully.
[    2.344532] systemd[1]: Finished modprobe@efi_pstore.service - Load Kernel Module efi_pstore.
[[0;32m  OK  [0m] Finished [0;1;39mmodprobe@efi_psto…m - Load Kernel Module efi_pstore.
[    2.347203] systemd[1]: modprobe@fuse.service: Deactivated successfully.
[    2.348142] systemd[1]: Finished modprobe@fuse.service - Load Kernel Module fuse.
[[0;32m  OK  [0m] Finished [0;1;39mmodprobe@fuse.service[0m - Load Kernel Module fuse.
[    2.350585] systemd[1]: modprobe@loop.service: Deactivated successfully.
[    2.351561] systemd[1]: Finished modprobe@loop.service - Load Kernel Module loop.
[[0;32m  OK  [0m] Finished [0;1;39mmodprobe@loop.service[0m - Load Kernel Module loop.
[    2.353920] systemd[1]: Finished systemd-modules-load.service - Load Kernel Modules.
[[0;32m  OK  [0m] Finished [0;1;39msystemd-modules-l…service[0m - Load Kernel Modules.
[    2.356350] systemd[1]: Finished systemd-remount-fs.service - Remount Root and Kernel File Systems.
[[0;32m  OK  [0m] Finished [0;1;39msystemd-remount-f…ount Root and Kernel File Systems.
[    2.359050] systemd[1]: Finished systemd-udev-trigger.service - Coldplug All udev Devices.
[[0;32m  OK  [0m] Finished [0;1;39msystemd-udev-trig…e[0m - Coldplug All udev Devices.
[    2.361690] systemd[1]: sys-fs-fuse-connections.mount - FUSE Control File System was skipped because of an unmet condition check (ConditionPathExists=/sys/fs/fuse/connections).
[    2.363732] systemd[1]: sys-kernel-config.mount - Kernel Configuration File System was skipped because of an unmet condition check (ConditionPathExists=/sys/kernel/config).
[    2.365659] systemd[1]: systemd-firstboot.service - First Boot Wizard was skipped because of an unmet condition check (ConditionFirstBoot=yes).
[    2.367245] systemd[1]: systemd-pstore.service - Platform Persistent Storage Archival was skipped because of an unmet condition check (ConditionDirectoryNotEmpty=/sys/fs/pstore).
[    2.378715] systemd[1]: Starting systemd-random-seed.service - Load/Save Random Seed...
         Starting [0;1;39msystemd-random-se…ice[0m - Load/Save Random Seed...
[    2.381562] systemd[1]: systemd-repart.service - Repartition Root Disk was skipped because no trigger condition checks were met.
[    2.383930] systemd[1]: Starting systemd-sysctl.service - Apply Kernel Variables...
         Starting [0;1;39msystemd-sysctl.se…ce[0m - Apply Kernel Variables...
[    2.387490] systemd[1]: Starting systemd-sysusers.service - Create System Users...
         Starting [0;1;39msystemd-sysusers.…rvice[0m - Create System Users...
[    2.390675] systemd[1]: Starting systemd-udev-settle.service - Wait for udev To Complete Device Initialization...
         Starting [0;1;39msystemd-udev-sett… Complete Device Initialization...
[    2.395392] systemd[1]: Started systemd-journald.service - Journal Service.
[[0;32m  OK  [0m] Started [0;1;39msystemd-journald.service[0m - Journal Service.
[[0;32m  OK  [0m] Finished [0;1;39msystemd-random-se…rvice[0m - Load/Save Random Seed.
[[0;32m  OK  [0m] Finished [0;1;39msystemd-sysctl.service[0m - Apply Kernel Variables.
[[0;32m  OK  [0m] Finished [0;1;39msystemd-sysusers.service[0m - Create System Users.
         Starting [0;1;39msystemd-journal-f…h Journal to Persistent Storage...
         Starting [0;1;39msystemd-tmpfiles-…ate Static Device Nodes in /dev...
[[0;32m  OK  [0m] Finished [0;1;39msystemd-tmpfiles-…reate Static Device Nodes in /dev.
[[0;32m  OK  [0m] Reached target [0;1;39mlocal-fs-pr…reparation for Local File Systems.
[[0;32m  OK  [0m] Reached target [0;1;39mlocal-fs.target[0m - Local File Systems.
         Starting [0;1;39msystemd-binfmt.se…et Up Additional Binary Formats...
         Starting [0;1;39msystemd-machine-i… a transient machine-id on disk...
         Starting [0;1;39msystemd-udevd.ser…ger for Device Events and Files...
[[0;32m  OK  [0m] Finished [0;1;39msystemd-journal-f…ush Journal to Persistent Storage.
         Mounting [0;1;39mproc-sys-fs-binfm…utable File Formats File System...
         Starting [0;1;39msystemd-tmpfiles-…te System Files and Directories...
[[0;32m  OK  [0m] Mounted [0;1;39mproc-sys-fs-binfmt…ecutable File Formats File System.
[[0;32m  OK  [0m] Finished [0;1;39msystemd-binfmt.se… Set Up Additional Binary Formats.
[[0;32m  OK  [0m] Finished [0;1;39msystemd-tmpfiles-…eate System Files and Directories.
[[0;32m  OK  [0m] Started [0;1;39mresolvconf.service… - Nameserver information manager.
[[0;32m  OK  [0m] Reached target [0;1;39mnetwork-pre…get[0m - Preparation for Network.
         Starting [0;1;39msystemd-update-ut…rd System Boot/Shutdown in UTMP...
[[0;32m  OK  [0m] Finished [0;1;39msystemd-update-ut…cord System Boot/Shutdown in UTMP.
[[0;32m  OK  [0m] Finished [0;1;39msystemd-machine-i…it a transient machine-id on disk.
[[0;32m  OK  [0m] Started [0;1;39msystemd-udevd.serv…nager for Device Events and Files.
[[0;32m  OK  [0m] Found device [0;1;39mdev-ttyS0.device[0m - /dev/ttyS0.
[[0;32m  OK  [0m] Listening on [0;1;39msystemd-rfkil…l Switch Status /dev/rfkill Watch.
[[0;32m  OK  [0m] Finished [0;1;39msystemd-udev-sett…To Complete Device Initialization.
[[0;32m  OK  [0m] Reached target [0;1;39msysinit.target[0m - System Initialization.
[[0;32m  OK  [0m] Started [0;1;39msystemd-tmpfiles-c… Cleanup of Temporary Directories.
[[0;32m  OK  [0m] Listening on [0;1;39mdbus.socket[…- D-Bus System Message Bus Socket.
[[0;32m  OK  [0m] Reached target [0;1;39msockets.target[0m - Socket Units.
         Starting [0;1;39mnetworking.service[0m - Network initialization...
[[0m[0;31m*     [0m] Job networking.service/start running (2s / no limit)
M[K[[0;32m  OK  [0m] Finished [0;1;39mnetworking.service[0m - Network initialization.
[K[[0;32m  OK  [0m] Reached target [0;1;39mnetwork.target[0m - Network.
         Starting [0;1;39mkdump-tools.servi…rnel crash dump capture service...
[    5.210977] kdump-tools[1160]: Starting kdump-tools:
[    5.212601] kdump-tools[1164]: Creating symlink /var/lib/kdump/vmlinuz.
[    5.249472] kdump-tools[1181]: kdump-tools: Generating /var/lib/kdump/initrd.img-6.1.55-arrcus
[    5.256375] kdump-tools[1190]: W: No zstd in /usr/bin:/sbin:/bin, using gzip
[    5.365824] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/skl_huc_2.0.0.bin for built-in driver i915
[    5.367737] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/bxt_huc_2.0.0.bin for built-in driver i915
[    5.370336] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/kbl_huc_4.0.0.bin for built-in driver i915
[    5.372306] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/glk_huc_4.0.0.bin for built-in driver i915
[    5.374174] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/kbl_huc_4.0.0.bin for built-in driver i915
[    5.376253] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/kbl_huc_4.0.0.bin for built-in driver i915
[    5.378401] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/cml_huc_4.0.0.bin for built-in driver i915
[    5.380340] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/icl_huc_9.0.0.bin for built-in driver i915
[    5.382375] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/ehl_huc_9.0.0.bin for built-in driver i915
[    5.384635] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/ehl_huc_9.0.0.bin for built-in driver i915
[    5.386673] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/tgl_huc_7.9.3.bin for built-in driver i915
[    5.388814] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/tgl_huc_7.9.3.bin for built-in driver i915
[    5.390620] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/dg1_huc.bin for built-in driver i915
[    5.392600] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/tgl_huc_7.9.3.bin for built-in driver i915
[    5.394444] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/tgl_huc.bin for built-in driver i915
[    5.396349] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/tgl_huc_7.9.3.bin for built-in driver i915
[    5.398173] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/tgl_huc.bin for built-in driver i915
[    5.399944] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/skl_guc_70.1.1.bin for built-in driver i915
[    5.401799] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/bxt_guc_70.1.1.bin for built-in driver i915
[    5.403797] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/kbl_guc_70.1.1.bin for built-in driver i915
[    5.405780] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/glk_guc_70.1.1.bin for built-in driver i915
[    5.407622] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/kbl_guc_70.1.1.bin for built-in driver i915
[    5.409461] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/kbl_guc_70.1.1.bin for built-in driver i915
[    5.411313] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/cml_guc_70.1.1.bin for built-in driver i915
[    5.413179] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/icl_guc_70.1.1.bin for built-in driver i915
[    5.415771] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/ehl_guc_70.1.1.bin for built-in driver i915
[    5.417950] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/ehl_guc_70.1.1.bin for built-in driver i915
[    5.419884] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/tgl_guc_70.1.1.bin for built-in driver i915
[    5.421816] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/tgl_guc_70.1.1.bin for built-in driver i915
[    5.423732] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/dg1_guc_70.bin for built-in driver i915
[    5.425595] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/tgl_guc_69.0.3.bin for built-in driver i915
[    5.427524] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/tgl_guc_70.1.1.bin for built-in driver i915
[    5.429424] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/tgl_guc_70.bin for built-in driver i915
[    5.431291] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/adlp_guc_69.0.3.bin for built-in driver i915
[    5.433231] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/adlp_guc_70.1.1.bin for built-in driver i915
[    5.435183] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/adlp_guc_70.bin for built-in driver i915
[    5.437092] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/dg2_guc_70.bin for built-in driver i915
[    5.439141] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/bxt_dmc_ver1_07.bin for built-in driver i915
[    5.441075] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/skl_dmc_ver1_27.bin for built-in driver i915
[    5.443024] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/kbl_dmc_ver1_04.bin for built-in driver i915
[    5.444964] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/glk_dmc_ver1_04.bin for built-in driver i915
[    5.446905] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/icl_dmc_ver1_09.bin for built-in driver i915
[    5.448859] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/tgl_dmc_ver2_12.bin for built-in driver i915
[    5.450798] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/rkl_dmc_ver2_03.bin for built-in driver i915
[    5.453095] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/dg1_dmc_ver2_02.bin for built-in driver i915
[    5.455645] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/adls_dmc_ver2_01.bin for built-in driver i915
[    5.457899] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/adlp_dmc_ver2_16.bin for built-in driver i915
[    5.460107] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/i915/dg2_dmc_ver2_07.bin for built-in driver i915
[    5.461967] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/tigon/tg3_tso5.bin for built-in driver tg3
[    5.463746] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/tigon/tg3_tso.bin for built-in driver tg3
[    5.465525] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/tigon/tg357766.bin for built-in driver tg3
[    5.468173] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/tigon/tg3.bin for built-in driver tg3
[    5.469937] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/e100/d102e_ucode.bin for built-in driver e100
[    5.471943] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/e100/d101s_ucode.bin for built-in driver e100
[    5.473839] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/e100/d101m_ucode.bin for built-in driver e100
[    5.475730] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/regulatory.db for built-in driver cfg80211
[    5.477546] kdump-tools[1364]: W: Possible missing firmware /lib/firmware/regulatory.db.p7s for built-in driver cfg80211
[    6.457400] kdump-tools[1164]: Creating symlink /var/lib/kdump/initrd.img.
[    6.616102] kdump-tools[1164]: loaded kdump kernel.
[[0;32m  OK  [0m] Finished [0;1;39mkdump-tools.servi…Kernel crash dump capture service.
[[0;32m  OK  [0m] Reached target [0;1;39mbasic.target[0m - Basic System.
[[0;32m  OK  [0m] Started [0;1;39maaa.service[0m - AAA Module (arcos).
         Starting [0;1;39marcos_init.service[0m - arcos_init Service...
         Starting [0;1;39matd.service[0m - Deferred execution scheduler...
         Starting [0;1;39mchrony.service[0m - chrony, an NTP client/server...
[[0;32m  OK  [0m] Started [0;1;39mcron.service[0m -…kground program processing daemon.
         Starting [0;1;39mdbus.service[0m - D-Bus System Message Bus...
         Starting [0;1;39me2scrub_reap.serv…e ext4 Metadata Check Snapshots...
         Starting [0;1;39meventmgr-on-boot.service[0m - Eventmgr (arcos)...
[[0;32m  OK  [0m] Started [0;1;39mhdw_wdt.service[0m - HDW_WDT Module (arcos).
         Starting [0;1;39mkexec-load.servic…B: Load kernel image with kexec...
         Starting [0;1;39mkmod_hdlr.service[0m - kmod_hdlr Service...
         Starting [0;1;39mlldpd.service[0m - LLDP daemon...
[[0;32m  OK  [0m] Started [0;1;39mlttng-sessiond.service[0m - LTTng session daemon.
         Starting [0;1;39mmemory_watchdog.s…nit.d for ArcOS memory_watchdog...
[[0;32m  OK  [0m] Started [0;1;39mresource_monitor.s…ce[0m - resource_monitor Service.
         Starting [0;1;39mrsyslog.service[0m - System Logging Service...
         Starting [0;1;39msetup-arcos.servi… environment for Arcos services...
         Starting [0;1;39mshared_mem_resize…[0m - shared_mem_resize Service...
         Starting [0;1;39msnmpd.service[0m…agement Protocol (SNMP) Daemon....
         Starting [0;1;39mssh-generate-host…hell server Host Key Generation...
[[0;32m  OK  [0m] Started [0;1;39mstrongswan-starter…Ev1/IKEv2 daemon using ipsec.conf.
         Starting [0;1;39msysstat.service[0m - Resets System Activity Logs...
         Starting [0;1;39msystemd-logind.se…ice[0m - User Login Management...
         Starting [0;1;39msystemd-user-sess…vice[0m - Permit User Sessions...
[[0;32m  OK  [0m] Started [0;1;39mdbus.service[0m - D-Bus System Message Bus.
[[0;32m  OK  [0m] Started [0;1;39mrsyslog.service[0m - System Logging Service.
[[0;32m  OK  [0m] Started [0;1;39mlldpd.service[0m - LLDP daemon.
[[0;32m  OK  [0m] Started [0;1;39msnmpd.service[0m …anagement Protocol (SNMP) Daemon..
[[0;32m  OK  [0m] Started [0;1;39matd.service[0m - Deferred execution scheduler.
[[0;32m  OK  [0m] Started [0;1;39mchrony.service[0m - chrony, an NTP client/server.
[[0;32m  OK  [0m] Finished [0;1;39meventmgr-on-boot.service[0m - Eventmgr (arcos).
[[0;32m  OK  [0m] Finished [0;1;39mkmod_hdlr.service[0m - kmod_hdlr Service.
[[0;32m  OK  [0m] Finished [0;1;39me2scrub_reap.serv…ine ext4 Metadata Check Snapshots.
[[0;32m  OK  [0m] Finished [0;1;39mshared_mem_resize…e[0m - shared_mem_resize Service.
[[0;32m  OK  [0m] Finished [0;1;39msysstat.service[0m - Resets System Activity Logs.
[[0;32m  OK  [0m] Finished [0;1;39msystemd-user-sess…ervice[0m - Permit User Sessions.
[[0;32m  OK  [0m] Started [0;1;39msystemd-logind.service[0m - User Login Management.
[[0;32m  OK  [0m] Started [0;1;39mkexec-load.service…LSB: Load kernel image with kexec.
[[0;32m  OK  [0m] Started [0;1;39mmemory_watchdog.se… init.d for ArcOS memory_watchdog.
[[0;32m  OK  [0m] Reached target [0;1;39mtime-sync.t…et[0m - System Time Synchronized.
[[0;32m  OK  [0m] Started [0;1;39mapt-daily.timer[0m - Daily apt download activities.
[[0;32m  OK  [0m] Started [0;1;39mapt-daily-upgrade.… apt upgrade and clean activities.
[[0;32m  OK  [0m] Started [0;1;39mdpkg-db-backup.tim… Daily dpkg database backup timer.
[[0;32m  OK  [0m] Started [0;1;39me2scrub_all.timer…etadata Check for All Filesystems.
[[0;32m  OK  [0m] Started [0;1;39mfstrim.timer[0m - Discard unused blocks once a week.
[[0;32m  OK  [0m] Started [0;1;39mlogrotate.timer[0m - Daily rotation of log files.
[[0;32m  OK  [0m] Started [0;1;39msysstat-collect.ti… accounting tool every 10 minutes.
[[0;32m  OK  [0m] Started [0;1;39msysstat-summary.ti…of yesterday's process accounting.
[[0;32m  OK  [0m] Reached target [0;1;39mtimers.target[0m - Timer Units.
         Starting [0;1;39marcos-user-init.s…ice[0m - ArcOS user management...
[[0;32m  OK  [0m] Started [0;1;39mgetty@tty1.service[0m - Getty on tty1.
[[0;32m  OK  [0m] Started [0;1;39mserial-getty@ttyS0…rvice[0m - Serial Getty on ttyS0.
[[0;32m  OK  [0m] Reached target [0;1;39mgetty.target[0m - Login Prompts.
         Stopping [0;1;39mkdump-tools.servi…rnel crash dump capture service...
[[0;32m  OK  [0m] Finished [0;1;39mssh-generate-host… Shell server Host Key Generation.
         Starting [0;1;39mssh.service[0m - OpenBSD Secure Shell server...
[    7.017465] kdump-tools[2780]: Stopping kdump-tools:
[    7.017655] kdump-tools[2784]: unloaded kdump kernel.
[[0;32m  OK  [0m] Stopped [0;1;39mkdump-tools.servic…Kernel crash dump capture service.
         Starting [0;1;39mkdump-tools.servi…rnel crash dump capture service...
[[0;32m  OK  [0m] Started [0;1;39mssh.service[0m - OpenBSD Secure Shell server.
[[0;32m  OK  [0m] Finished [0;1;39msetup-arcos.servi…et environment for Arcos services.
[    7.064599] kdump-tools[2806]: Starting kdump-tools:
[    7.064857] kdump-tools[2810]: Creating symlink /var/lib/kdump/vmlinuz.
[    7.067107] kdump-tools[2810]: Creating symlink /var/lib/kdump/initrd.img.
[    7.073801] kdump-tools[2810]: /etc/default/kdump-tools: KDUMP_KERNEL does not exist: None ... failed!
[[0;32m  OK  [0m] Finished [0;1;39mkdump-tools.servi…Kernel crash dump capture service.
[[0;32m  OK  [0m] Finished [0;1;39marcos-user-init.service[0m - ArcOS user management.
2026-01-22 18:59:49 ArcOS arcos_init INFO: Cmd ['python3', '/usr/share/arcos/gen_confd_conf.py'] successful.
[[0;32m  OK  [0m] Stopped [0;1;39mlogrotate.timer[0m - Daily rotation of log files.
         Stopping [0;1;39mlogrotate.timer[0m - Daily rotation of log files...
[[0;32m  OK  [0m] Started [0;1;39mlogrotate.timer[0m - Daily rotation of log files.
         Stopping [0;1;39mssh.service[0m - OpenBSD Secure Shell server...
[[0;32m  OK  [0m] Stopped [0;1;39mssh.service[0m - OpenBSD Secure Shell server.
[[0;32m  OK  [0m] Finished [0;1;39marcos_init.service[0m - arcos_init Service.
[[0;32m  OK  [0m] Started [0;1;39mconfd.service[0m - confd Service.
         Starting [0;1;39mconfd_phase0_chec…0m - confd_phase0_check Service...
[[0;32m  OK  [0m] Finished [0;1;39mconfd_phase0_chec…[0m - confd_phase0_check Service.
         Starting [0;1;39mconfd_vp_reg_chec…0m - confd_vp_reg_check Service...
         Starting [0;1;39mmarker.service[0m - marker Service...
[[0;32m  OK  [0m] Finished [0;1;39mmarker.service[0m - marker Service.
[[0;32m  OK  [0m] Started [0;1;39marcos_mps.service…cOS Message Passing Service (MPS).
[[0;32m  OK  [0m] Started [0;1;39maaa_conf.service[0m - aaa_conf Service.
[[0;32m  OK  [0m] Started [0;1;39macl.service[0m - acl Service.
[[0;32m  OK  [0m] Started [0;1;39macl_helper.service[0m - acl_helper Service.
[[0;32m  OK  [0m] Started [0;1;39madjmgr.service[0m - adjmgr Service.
[[0;32m  OK  [0m] Started [0;1;39mapcmgr.service[0m - apcmgr Service.
[[0;32m  OK  [0m] Started [0;1;39mbfd.service[0m - bfd Service.
[[0;32m  OK  [0m] Started [0;1;39mbgp.service[0m - bgp Service.
[[0;32m  OK  [0m] Started [0;1;39mchassismgr.service[0m - chassismgr Service.
[[0;32m  OK  [0m] Started [0;1;39mdpal.service[0m - dpal Service.
[[0;32m  OK  [0m] Started [0;1;39mdra.service[0m - dra Service.
         Starting [0;1;39meventmgr-on-arcos…eventmgr-on-arcos-start Service...
[[0;32m  OK  [0m] Started [0;1;39meventmgr.service[0m - eventmgr Service.
[[0;32m  OK  [0m] Started [0;1;39mfib.service[0m - fib Service.
[[0;32m  OK  [0m] Started [0;1;39mgnmi.service[0m - gnmi Service.
[[0;32m  OK  [0m] Started [0;1;39mifmgr.service[0m - ifmgr Service.
[[0;32m  OK  [0m] Started [0;1;39mip.service[0m - ip Service.
[[0;32m  OK  [0m] Started [0;1;39mipfix.service[0m - ipfix Service.
[[0;32m  OK  [0m] Started [0;1;39mkey_chain.service[0m - key_chain Service.
[[0;32m  OK  [0m] Started [0;1;39ml2featmgr.service[0m - l2featmgr Service.
[[0;32m  OK  [0m] Started [0;1;39ml2rib.service[0m - l2rib Service.
[[0;32m  OK  [0m] Started [0;1;39ml3fm.service[0m - l3fm Service.
[[0;32m  OK  [0m] Started [0;1;39mlblmgr.service[0m - lblmgr Service.
[[0;32m  OK  [0m] Started [0;1;39mli.service[0m - li Service.
[[0;32m  OK  [0m] Started [0;1;39mlicmgr.service[0m - licmgr Service.
[[0;32m  OK  [0m] Started [0;1;39mlldp_service.service[0m - lldp_service Service.
[[0;32m  OK  [0m] Started [0;1;39mlldp.service[0m - lldp Service.
[[0;32m  OK  [0m] Started [0;1;39mmacsec.service[0m - macsec Service.
[[0;32m  OK  [0m] Started [0;1;39mmonitor.service[0m - monitor Service.
[[0;32m  OK  [0m] Started [0;1;39mntp_snmp.service[0m - ntp_snmp Service.
[[0;32m  OK  [0m] Started [0;1;39mpltfAgent.service[0m - pltfAgent Service.
[[0;32m  OK  [0m] Started [0;1;39mpltfServer.service[0m - pltfServer Service.
[[0;32m  OK  [0m] Started [0;1;39mptp.service[0m - ptp Service.
         Starting [0;1;39mqos.service[0m - qos Service...
[[0;32m  OK  [0m] Started [0;1;39mrad.service[0m - rad Service.
[[0;32m  OK  [0m] Started [0;1;39mrib.service[0m - rib Service.
[[0;32m  OK  [0m] Started [0;1;39mldp.service[0m - ldp Service.
[[0;32m  OK  [0m] Started [0;1;39mrpol.service[0m - rpol Service.
[[0;32m  OK  [0m] Started [0;1;39msflow.service[0m - sflow Service.
[[0;32m  OK  [0m] Started [0;1;39msidmgr.service[0m - sidmgr Service.
[[0;32m  OK  [0m] Started [0;1;39msla.service[0m - sla Service.
[[0;32m  OK  [0m] Started [0;1;39msmd.service[0m - smd Service.
         Starting [0;1;39mspyder.service[0… Spyder Process Manager (arcos)...
[[0;32m  OK  [0m] Started [0;1;39msrpolicy.service[0m - srpolicy Service.
[[0;32m  OK  [0m] Started [0;1;39msrv6oam.service[0m - srv6oam Service.
[[0;32m  OK  [0m] Started [0;1;39mstp.service[0m - stp Service.
[[0;32m  OK  [0m] Started [0;1;39msys_conf.service[0m - sys_conf Service.
[[0;32m  OK  [0m] Started [0;1;39msysmgr.service[0m - sysmgr Service.
[[0;32m  OK  [0m] Started [0;1;39mtelemetry.service[0m - telemetry Service.
[[0;32m  OK  [0m] Started [0;1;39mtwamp_reflector.se…ice[0m - twamp_reflector Service.
[[0;32m  OK  [0m] Started [0;1;39mtwamp_ssender.service[0m - twamp_ssender Service.
[[0;32m  OK  [0m] Started [0;1;39mvrfmgr.service[0m - vrfmgr Service.
[[0;32m  OK  [0m] Finished [0;1;39meventmgr-on-arcos…- eventmgr-on-arcos-start Service.

Debian GNU/Linux 12 localhost ttyS0

localhost login: 2026-01-22 19:01:01 ArcOS arcos.startup_config INFO: snmp enable is False, skipping sys descr update
2026-01-22 19:02:02 ArcOS arcos.startup_config INFO: Global_Config_Trigger: The following services did not subscribe to CDB within 60 seconds: {'l3fm.service'}
[  140.090939] process '/usr/sbin/mstpd' started with executable stack
2026-01-22 19:02:17 ArcOS ztp INFO: Starting Zero Touch Provisioning (ZTP). Please do not change the system configuration during this time. To stop and disable ZTP run CLI command: "request system ztp stop"
2026-01-22 19:02:17 ArcOS ztp INFO: Trying to bring interfaces up
2026-01-22 19:02:30 ArcOS ztp INFO: Sending DHCP requests on interfaces [ma1]
2026-01-22 19:02:35 ArcOS ztp INFO: No DHCP responses received with config-url or script-url options. Retrying...
2026-01-22 19:02:48 ArcOS ztp INFO: Sending DHCP requests on interfaces [ma1]
2026-01-22 19:02:54 ArcOS ztp INFO: Received DHCP response on ma1 with IP address 192.168.132.187, subnet mask 255.255.255.0, option config-url http://192.168.132.1/arrcus/ztp/base.cfg
2026-01-22 19:03:09 ArcOS ztp INFO: Fetching file from URL http://192.168.132.1/arrcus/ztp/base.cfg
2026-01-22 19:03:09 ArcOS ztp INFO: Applying ZTP configuration
2026-01-22 19:03:14 ArcOS ztp INFO: ZTP configuration applied successfully
2026-01-22 19:03:14 ArcOS ztp INFO: Zero Touch Provisioning completed successfully

Running text console command: virsh --connect qemu:///system console Prem-TB1-rtr2
Domain creation completed.

VM Prem-TB1-rtr2 running ... ( vnc: 192.168.1.13:5901 )

❯ brctl show Prem-TB1-br1 Prem-TB1-br2
bridge name     bridge id               STP enabled     interfaces
Prem-TB1-br1            8000.ba241ae5a696       no              vnet25
                                                        vnet31
Prem-TB1-br2            8000.aa1efef8d8d9       no              vnet26
                                                        vnet32

❯ virsh list
 Id   Name            State
-------------------------------
 21   Prem-TB1-rtr1   running
 23   Prem-TB1-rtr2   running
```

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
