Phase 1: Foundations
-Install Proxmox
Use Rufus to create a boot drive.
Ensure that you're using an Ethernet connection.
Install from the boot menu and use the graphical interface.
Select your drive configuration.
Set your country and timezone.
Enter a strong password and email address.
Network Configuration:
Ensure the correct Ethernet port is selected.
Set a name for your machine, such as pve.server.local.
Set an unused local IP address, such as 192.168.0.100/24.
Set your router's actual gateway, such as 192.168.0.1.
Set your DNS to your router's gateway.
Reboot after installation.
Navigate to https://192.168.0.100:8006 on your computer to access the Proxmox interface.
Username: root
Password: The one you set during installation.
If you are running Proxmox on a laptop, you can use the commands in the laptop_config script to monitor the battery and prevent the system from sleeping when the lid is closed.

-Create Ubuntu Server VM Template
Click Create VM (top-right corner).
General
VM ID: 101
Name: Docker
OS
ISO Image: Ubuntu Server
Disks
Disk Size: Set to your preference.
CPU
Sockets: 1
Cores: 2
Memory
Memory: Set based on your system's availability (recommend at least 6GB).
Confirm and create.
Open the shell of your new VM and install Ubuntu Server.
Under Network Configuration, manually configure your connection.
IPv4 Method: Manual
Subnet: 192.168.0.0/24
Address: 192.168.0.101
Gateway: 192.168.0.1
Name Servers: 192.168.0.101 (Your Pi-hole VM's IP once installed)
Search Domains: local
Set your login details.
Use GitHub to install and import OpenSSH Server and your SSH keys.
Wait for the installation to complete and reboot.
Establish SSH Environment on Your Home Computer
Open Command Prompt and generate a key pair.
Store the key pair in a secure location, such as C:/User/user/.ssh/.
Set the permissions for the key pair.
```
cd C:/Path/to/.ssh
icacls id_rsa /inheritance:r
icacls id_rsa /grant:r "<your user>":F
```

-Setup Docker/PiHole
Install Docker
```
sudo apt-get update && sudo apt-get upgrade -y

for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

sudo apt-get update
sudo apt-get install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```
Create a .env file
```
DOMAIN="domain.org"
PIHOLE_WEB_PASS="password"
WG_PASS="password"
```

-Configure Router DHCP DNS to use PiHole

Phase 2: Secure Access & Services
-Install wg-easy and caddy
-Configure NameCheap DDNS
-Create Cloud Instance
-Establish site-to-site VPN

Phase 3: Centralized Monitoring
-Install Prometheus and Grafana in the Cloud Instance
-Install Node-Exporter and cAdvisor
-Configure Prometheus to scrape the home server over the VPN tunnel
-Refine Grafana Dashboards and configure Alertmanager

Phase 4: Security and Micro-Segmentation
-Create a public network for Caddy
-Create a private network for other services (Caddy is on both networks)
-Consider a software firewall like UFW on the Docker VM

Phase 5: Deploying Additional Services
-LLDAP
-Actual Budget
-Homepage
-Vaultwarden

Phase 6: Advanced Services
-Install Samba
-Install Nextcloud

Phase 7: HomeAssistant
-Install HomeAssistant OS

Phase 8: Refine Documentation and Polish
-Finalize GitHub repo and MkDocs site

Phase 9: Email
-Tackle an email server

