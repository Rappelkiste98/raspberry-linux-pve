
# Raspbian Linux Kernel for Proxmox ARM64

This Repository is for all "Proxmox ARM64" Instances running on a Raspberry PI 4B.  
You can use this pre-build Linux Kernel for better compatibility with Proxmox without building it your self.

## Related

[Proxmox-Port by jiangcuo](https://github.com/jiangcuo/Proxmox-Port)  
[Proxmox-Arm64 by jiangcuo](https://github.com/jiangcuo/Proxmox-Arm64)  
[RaspberryPi Kernel Sourcecode](https://github.com/raspberrypi/linux)

## Features

- RamDisk Boot
- OpenZFS Support
- KSM Kernel Support
- VLAN Filtering

## Installation

Download the newest Kernel Version ([6.1.*](https://github.com/Rappelkiste98/pve-raspbian/tree/6.1.y))
```bash
wget -q --show-progress https://github.com/Rappelkiste98/pve-raspbian/releases/download/6.1.58/linux-headers-6.1.58-pve_arm64.deb &&
wget -q --show-progress https://github.com/Rappelkiste98/pve-raspbian/releases/download/6.1.58/linux-image-6.1.58-pve_arm64.deb
```
Install new Kernel Image
```bash
sudo apt install $PWD/linux-image-6.1.58-pve+-5_arm64.deb
```

Install new Kernel Headers
```bash
sudo apt install $PWD/linux-headers-6.1.58-pve+-5_arm64.deb
```

Configure Boot settings for new installed Kernel
```bash
sudo nano /boot/config.txt

At File End add this Lines:
[pi4]
kernel=vmlinuz-6.1.58-pve+
initramfs initrd.img-6.1.58-pve+ followkernel
```

Hold official RaspberryPi Kernel APT Packages (APT doesn't upgrade this Packages after this Settings)
```bash
sudo apt-mark hold raspberrypi-kernel raspberrypi-kernel-headers
```

Reboot your RaspberryPi and Check used Kernel
```bash
uname -r => 6.1.58-pve
```
## FAQ

#### How can I check that the KSM Module is installed?
```bash
sudo modprobe drm_kms_helper => No Return Value is fine
sudo cat /sys/kernel/mm/ksm/run => '0' Or '1' (KSM activates automatically at 70& RAM Usage)
sudo cat /sys/kernel/mm/ksm/pages_shared => '0' Or Bigger
```

#### How to activate KSM Features in Proxmox?
```bash
sudo apt install ksmtuned
sudo systemctl enable --now ksm.service
sudo systemctl enable --now ksmtuned.service
```

## Troubleshooting

#### Raspberry Pi doesn't boot after Kernel installation
    1. Take your Raspberry PI Boot-Device (USB HDD/SSD OR SD-Card) and connect it to another Computer
    2. Open the "config.txt" on the Bootpartion
    3. Uncomment the new attached Lines:
        #kernel=vmlinuz-6.1.58-pve+ initramfs
        #initrd.img-6.1.58-pve+ followkernel
    4. Save "config.txt" and connect it to the Raspberry PI
    5. Reboot Raspberry PI
Now the Default Raspbian Linux Kernel is used.
