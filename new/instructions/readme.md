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
### Docker
Caddy and PiHole
Install Docker
```
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```


### WireGuard




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
