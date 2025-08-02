<div align="center">
    <picture>
        <img width="700" height="200" alt="Another_Juvenile_Home_Server" src="https://github.com/user-attachments/assets/9dacd65e-2d37-4f58-95a1-5ea009c7ce2b" />
        <img src="docs/assets/HomeLab.drawio.svg alt="Diagram"
[Documentation]
</div>
        
[Documentation]: https://homelab.nolandonahue.org

---
![Network](docs/assets/HomeLab.drawio.svg)

## Hardware

### Testbench

Acer Swift 5
8gb Ram
256gb SSD

### Production

Dell Vostro 3670
16gb Ram
500gb NVME
1tb HDD

### Router and Network

TP-Link AX55 AC3000
TP-Link 5port 1gb switch

## Network and Environment

Currently using a TP-Link AX55 AC3000 with the goal of switching to OpnSense in the future to create VLANs

### Structure
```
SWIFT Development Environment                         MAIN Production Environment
192.168.0.15x/24 Network                              192.168.9.10x/24 Network
├── 🔵 Proxmox - 192.168.0.150/24                    ├── 🔵 Proxmox - 192.168.0.150/24
├── 🟢 VPN - 192.168.151/24                          ├── 🟢 VPN - 192.168.151/24  
├── 🔴 FileShare - 192.168.0.152/24                  ├── 🔴 FileShare - 192.168.0.152/24 
├── 🟠 ReverseProxy/Hosting - 192.168.0.153/24       └── 🟠 ReverseProxy/Hosting - 192.168.0.153/24 
└── 🟣 CatCamera - 192.168.0.154/24
    
```
![Network] (docs/assets/network.drawio.svg)

## Program List

### Host
Proxmox hosting Ubuntu Server VMs with LVM-Thin storage

### VPN
WireGuard from CLI

### FileShare
Samba from Docker Compose

### ReverseProxy/Hosting
Caddy from CLI
Website files for self hosting
HomePage from Docker Compose

### CatCamera
None / Will be used for a local USB camera to record the cat for when the wife is away

## Related Projects
- [sfcal/homelab](https://github.comsfcal/homelab) - The best homelab tech support on the WWW

## License

This project is licensed under the GPLv3 License - see the LICENSE file for details.
