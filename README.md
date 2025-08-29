<div align="center">
    <picture>
        <img width="700" height="200" alt="Another_Juvenile_Home_Server" src="https://github.com/user-attachments/assets/9dacd65e-2d37-4f58-95a1-5ea009c7ce2b" />
</div>

---

- [Hardware](#hardware)
  - [Server](#server)
  - [Access Point](#access-point)
  - [Switch](#switch)
- [Network](#network)
  - [Structure](#structure)
- [Software](#software)
  - [Hypervisor](#hypervisor)
  - [Router](#router)
- [Related Projects](#related-projects)
- [License](#license)

# Hardware

## Server

Dell Vostro 3670
i3-8100 @3.6ghz (1 socket, 4 core)
32gb Ram (DDR4, 2666)
Intel 82576 NIC (2x1gb)
500gb NVME
1tb HDD

## Access Point

TP-Link AX55 AC3000 set to Access Point Mode

## Switch

TP-Link 5 Port 1gb Unmanaged Switch

# Network

![Network](docs/assets/Network.drawio.svg)

## Structure

In the short term I am running a simple network without VLANs. I plan to implement VLANs to increase network security.

# Software

![Software](docs/assets/Server.drawio.svg)

## Hypervisor

Proxmox is running as the hypervisor and backup solution with remote backups stored in an Oracle Cloud Instance and local Desktop

## Router

OPNsense is running as the router for the network using Unbound DNS with Hagezi blocklists. It handles the reverse proxy service using HA Proxy, the Certificate Authority service using ACME Client, and the VPN service using OpenVPN.

# Related Projects

- [sfcal/homelab](https://github.com/sfcal/homelab) - The best homelab tech support on the WWW

# License

This project is licensed under the GPLv3 License - see the LICENSE file for details.
