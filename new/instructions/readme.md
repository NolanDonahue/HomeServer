# How-To

## Proxmox
Install proxmox
Download Ubuntu Server ISO
Upload Ubuntu Server ISO

## Create a VM
Network Configuration
-Subnet:  192.168.0.0/24
-Address: 192.168.0.XXX
-Gateway: 192.168.0.1
-Name Server: 8.8.8.8, 8.8.4.4
-Search Domains: 

## VM1 - Main
### WireGuard

### Docker
Caddy and PiHole
```

```

# Checklist
## HomeServer

### PVE - Proxmox
Node-Exporter
  [ ] accessible on the local connection
  [ ] configured

### VM 1 - Main
HomePage
  [ ] accessible on the local connection
  [ ] configured
Actual Budget
  [ ] accessible on the local connection
  [ ] configured
Vaultwarden
  [ ] accessible on the local connection
  [ ] configured
Frigate
  [ ] accessible on the local connection
  [ ] configured
PiHole
  [ ] accessible on the local connection
  [ ] configured
Caddy
  [ ] accessible on the local connection
  [ ] configured
cAdvisor
  [ ] accessible on the local connection
  [ ] configured
Ansible
  [ ] accessible on the local connection
  [ ] configured

### VM 2 - Samba
Samba
  [ ] accessible on the local connection
  [ ] configured

### VM 3 - Home Assistant OS
  [ ] accessible on the local connection
  [ ] configured

## Cloud Oracle
  [ ] Instance created
  [ ] Instance connects to the internet
  [ ] Installed Prometheus
  [ ] Installed Grafana
  [ ] Prometheus pulls data from Home Server
  [ ] Grafana creates dashboard
  [ ] Website hosted
