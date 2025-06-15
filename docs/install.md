# Installing Low-level Data Aggregator

I developed this application on a Linux systems with an AMD CPU (x86_64 ISA). I compiled DPDK using the 
-Dplatform=generic to make the application portable; however, you may wish to build using one (or all) 
of the build options.  I developed this application to run in a heterogenius environment.

### Spec Your System
We've all done it —— you skip the `system requirements` section when installing an application; after all, 
the type of people interested in this work are most likely using a beefy server with plenty of RAM and disk
space, running Linux, with a clean installation environment——why would your server have any issues?

I strongly suggest not doing this when installing DPDK.  Follow the [DPDK System Requirements](https://doc.dpdk.org/guides/linux_gsg/sys_reqs.html#) guide and make sure you're working on a system that can support DPDK.  I will include application specific requirements and suggestions below.

### System Verification
Check for vfio.  If no module is present, try using `modprobe`:

```
lsmod | grep vfio
sudo modprobe vfio
sudo modprobe vfio-pci
```

Check if IOMMU is enabled; if disable, VFIO will not work properly. Note, that it's possible that IOMMU is enabled, but won't explicitly read `enabled`—see below.  Note, this doesn't guarantee passthrough is permitted.
See instructions below to troubleshoot.

```
dmesg | grep -i iommu

(Example Output Showing enabled)

root@localhost:~/dpdk-25.03/build# dmesg | grep -i iommu
[    0.594754] iommu: Default domain type: Translated
[    0.595180] iommu: DMA domain TLB invalidation policy: lazy mode
root@localhost:~/dpdk-25.03/build#
```

Check Ethernet Device

```
lspci -nn | grep -i eth

(*Your NIC interface may not have the eth prefix*)
```

Check NIC binding status

```
./usertools/dpdk-devbind.py --status
---

Network devices using kernel driver
===================================
0000:00:04.0 'Virtio network device 1000' if=eth0 drv=virtio-pci unused=vfio-pci *Active*
```

Note that binding your nic to vfio-pci will give DPDK control over the nic, and the typical 
kernel networking static will no longer be used.  Thus, *you will lose SSH capability on that NIC*,
so if it's your main NIC, make sure you connect via console first and make sure all code is deployed.
You can unbind a NIC (from console) by restarting networking.

```
./usertools/dpdk-devbind.py --bind=<driver> <pci_id>

-- Example --
./usertools/dpdk-devbind.py --bind=vfio-pci 0000:00:04.0
```

If you receive an error about IOMMU being disabled, vfio passthrough isn't enabled.  If using KVM, you can enable it by following [KVM VT-d instructions](https://www.linux-kvm.org/page/How_to_assign_devices_with_VT-d_in_KVM).  You'll likely have to clone the linux repo to /usr/src/

- The instructions linked above tell you to navicate to "Bus options (PCI etc.)" however, on my kernel,
I had to navigate to:
```
Device Drivers  --->
  IOMMU Hardware Support  --->
```

Note: If you'd like to change IOMMU default domain type, navigate to :
```
Device Drivers  --->
  IOMMU Hardware Support  --->
    IOMMU default domain type (Translated - Lazy)  --->

```

See the Following to Learn more:
    - [Kernel Docs Reference - IOMMU](https://docs.kernel.org/arch/x86/iommu.html)
    - [IOMMU in the Linux Kernel](iommu-linux-kernel.pdf)
    - [HPC Tuning for EPYC 7002 Series](hpc_epyc_7002.pdf)
    - [HPC Tuning for EPYC 7003 Series](hpc_epyc_7003.pdf)
    - [Workload Tuning for EPYC 7003 Series](workload_epyc_7003.pdf)
    - [DPDK Tuning for 8004 Series](dpdk_epyc_8004.pdf)
    - [Windows Network Tuning for 8004](windows_network_tuning.pdf) *This is for Windows but may serve as a helpful reference on Linux*

### Performance Build Options:
meson setup build -Dplatform=native

### Architecture Code Optimizations
You may wish to include a header file in include/arch that includes architecture specific macros, attributes,
and definitions.  I've included some for common use and a few for AMD.  

Note: The file structure of include/arch/x86 has separate folders for AMD and intel which include arch specific 
options.  Header files in the x86 parent folder are applicable for any x86_64 ISA

Some useful links:
-https://gcc.gnu.org/onlinedocs/gcc/Function-Attributes.html
-https://en.wikipedia.org/wiki/X_macro

# Additional Menuconfig options

- NUMA Emulation
- Per-cpu Memory statistics
- CMA (Contiguous Memory Allocator)
- Network Debugging:
    - Enable net device refcount tracking
    - Enable networking namespace refcount tracking
    - Add generic networking debug
    