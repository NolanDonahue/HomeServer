DISCUSSIONS
Why Are We Doing This?
1. Why are we using vpn.${DOMAIN} for the WG_HOST?
  It employs NameCheaps baked in DDNS to bypass any IPV4 issues if our routers IP Address changes. Because the A Records will automatically update, both wg-easy and caddy will be unaffected because the services they point to are maintained by NameCheaps DDNS

Problems
1. A Records and security
   During the process of recreating my HomeLab with an increased focus on security I misunderstood that A Records exposed my services to the internet in an unsecure way. But, obfuscation is not security and the methods used should be secure even if the world knows who and where you are. This was a great moment to redefine how I interacted with updating and maintaining the security of the lab. It also took a week of breaking everything to come to this realization!

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
```
Create a docker-compose.yml file
```
services:
  pihole:
    container_name: pihole
    image: pihole/pihole:latest
    environment:
      TZ: "America/New_York"
      WEBPASSWORD: ${PIHOLE_WEB_PASS}
      PIHOLE_DNS: 1.1.1.1, 9.9.9.9
      VIRTUAL_HOST: pihole.nolandonahue.org
      WEBTHEME: default-dark
      PIHOLE_DOMAIN: lan
    volumes:
      - './etc-pihole/:/etc/pihole/'
      - './etc-dsnmasq.d/:/etc/dnsmasq.d/'
    restart: unless-stopped
    network_mode: host
```
Run docker
```
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
sudo docker compose up -d
```

-Configure Router DHCP DNS to use PiHole
set the VM IP hosting pihole as your DHCPs DNS service, all future VMs should use this IP for their DNS as well. You can check ip with `ip a | grep /24`

-Configure NameCheap DDNS
Add A records for @, www, budget, pve, pihole, and vpn pointing at your home IP (whatismyip.com) and automatic
Port forward on your router for IP 192.168.0.102 ports 80/80(TCP), 443/443(TCP), and 51820(USP)

-Configure PiHole
Use Pihole Local DNS to point your services from your subdomains to caddy for reverse proxy, you will point subdomain.your.domain to 192.168.0.102. Your subdomains should be www, your.domain, vpn, pve, budget, pihole

-Setup Caddy and wg-easy
Create a new VM and install docker
create a docker-compose.yml
```
services:
  wg-easy:
    environment:
      - WG_HOST=vpn.${DOMAIN}
      - PASSWORD_HASH=${WG_PASS}
      - INSECURE=true
      - WG_ALLOWED_IPS=10.8.0.0/24, 192.168.0.0/24
      - WG_DEFAULT_DNS="192.168.0.101"
    image: ghcr.io/wg-easy/wg-easy:latest
    container_name: wg-easy
    hostname: wg-easy
    volumes:
      - ~/.wg-easy:/etc/wireguard
    ports:
      - "51820:51820/udp"
      - "51821:51821/tcp"
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv4.conf.all.src_valid_mark=1
    networks:
      - wg_network
  caddy:
    container_name: caddy
    image: caddy:latest
    restart: unless-stopped
    network_mode: host
    volumes:
      - $PWD/Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
      - ./website:/srv
    environment:
      - DOMAIN=${DOMAIN}
    dns:  
      - 8.8.8.8
volumes:
  caddy_data:
    name: caddy_data
  caddy_config:
    name: caddy_config
networks:
  wg_network:
    name: wg_network
    driver: bridge
```
Create a Caddyfile #TODO This is a temporary testing Caddyfile where removing the general block will use let's encrypt, then remove the commented area
```
{
    debug
    acme_ca https://acme-staging-v02.api.letsencrypt.org/directory
}
{$DOMAIN}, www.{$DOMAIN} {
    root * /srv
    file_server
    tls internal
}
pihole.{$DOMAIN} {
    redir / /admin
    reverse_proxy http://192.168.0.101:80
    tls internal
}
pve.{$DOMAIN} {
    reverse_proxy https://192.168.0.100:8006 {
        #Only use during timeout of let's encrypt
        header_up Host {http.request.host}
        header_up X-Forwarded-Proto {http.request.scheme}
        header_up X-Forwarded-For {http.request.remote}
        #End let's encrypt timeout use case
        transport http {
            tls_insecure_skip_verify
        }
    }
    tls internal
}
vpn.{$DOMAIN} {
    reverse_proxy http://192.168.0.102:51821
    tls internal
}
```
Fill out your .env
```
#Global
DOMAIN="domain.org"
#WireGuard
WG_PASS="hashed_password"
```
Run these commands (edit the one to hash your wireguard password with what you want the password to be)
```
sudo ufw allow 51820 #Only for Wg-Easy system
sudo ufw allow from 192.168.0.0/24 to any port 22
sudo ufw allow from 10.8.0.0/24 to any port 22 #Replace 10.8.0.0 with the wireguard internal IP you use
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
sudo docker compose pull
sudo docker compose up -d
sudo docker run --rm python sh -c "pip install bcrypt && python -c 'import bcrypt; print(bcrypt.hashpw(b\"password\", bcrypt.gensalt()).decode())'" #this will generate the hashed WG password edit it to use your desired password
```
Copy and paste the password hash into the environment variable then run
```
sudo docker compose down --remove-orphans && sudo docker compose up -d
```
Phase 2: Secure Access & Services
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

