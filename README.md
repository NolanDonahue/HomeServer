<div align="center">
    <picture>
        <img width="700" height="200" alt="Another_Juvenile_Home_Server" src="https://github.com/user-attachments/assets/9dacd65e-2d37-4f58-95a1-5ea009c7ce2b" />
</div>

---

- [Hardware](#hardware)
  - [Testbench](#testbench)
  - [Production](#production)
  - [Router and Network](#router-and-network)
- [Network and Environment](#network-and-environment)
  - [Structure](#structure)
- [Program List](#program-list)
  - [Host](#host)
  - [VPN](#vpn)
  - [FileShare](#fileshare)
  - [ReverseProxy/Hosting](#reverseproxyhosting)
- [Future Plans](#future-plans)
- [Related Projects](#related-projects)
- [License](#license)


# Hardware

![Network](docs/assets/HomeLab.drawio.svg)

## Testbench

Acer Swift 5
8gb Ram
256gb SSD

## Production

Dell Vostro 3670
i3-8100 @3.6ghz (1 socket, 4 core)
16gb Ram (DDR4, 2666)
500gb NVME
1tb HDD

## Router and Network

TP-Link AX55 AC3000
TP-Link 5port 1gb switch

# Network and Environment

Currently using a TP-Link AX55 AC3000 with the goal of switching to OpnSense in the future to create VLANs

## Structure
```
SWIFT Development Environment                         MAIN Production Environment
192.168.0.15x/24 Network                              192.168.9.10x/24 Network
├── 🔵 Proxmox - 192.168.0.150/24                    ├── 🔵 Proxmox - 192.168.0.100/24
├── 🟢 VPN - 192.168.151/24                          ├── 🟢 VPN - 192.168.101/24  
├── 🔴 FileShare - 192.168.0.152/24                  ├── 🔴 Docker - 192.168.0.102/24 
└── 🟠 ReverseProxy/Hosting - 192.168.0.153/24       └── 🟠 HomeAssistant (OS) - 192.168.0.103/24 
    
```

# Program List

## Host
Proxmox hosting Ubuntu Server VMs with LVM-Thin storage

## VPN
WireGuard from CLI

## FileShare
Samba from Docker Compose

## ReverseProxy/Hosting
Caddy from CLI
Website files for self hosting
HomePage from Docker Compose

# Future Plans
## Cloud Services
Create a free account on either AWS, Azure, or Google Cloud and host a light machine with the website host files
- Learning cloud storage, CDN, cloud security
- Create a cloud backup of the proxmox instance

## Monitoring
Employ Prometheus and Grafana via Docker to scrape metrics
- Prometheus to watch server metrics
- Grafana to watch hardware metrics

## Security Scans
Employ Nmap to scan my network
Employ Lynis or OpenVAS for security auditing

## Ansible
Build Ansible for an Infrastructure as Code approach

# Related Projects
- [sfcal/homelab](https://github.com/sfcal/homelab) - The best homelab tech support on the WWW

# License

This project is licensed under the GPLv3 License - see the LICENSE file for details.
