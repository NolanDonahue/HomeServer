# How-To

## Establish SSH environment on your home computer
Open Command Prompt
Generate a key pair
  Key pair should be stored somewhere like C:/User/user/.ssh/ as id_rsa
Set permissions of key pair
```
cd C:/Path/to/.ssh
icacls id_rsa /inheritance:r
icacls id_rsa /grant:r "<your user>":F
REM icacls id_rsa.pub /remove "Everyone" < Use this if the others are causing problems with your public key connecting
```
Connect to your PVE shell in Proxmox
```
nano /etc/sysctl.conf
```
set 'net.ipv4.ip_forward=1' and save
```
sysctl -p
```

## Setup domain A Records
Type: A Record
Host: <make one for all the ones below>
IP Address: <Your Home IP>
TTL: Automatic

All Hosts to create records for:
  @, budget, cadvisor, dashboard, home, monitor, node-exporter, pihole, prometheus, pve, vault, vpn, www

## Setup router port forwarding
Device IP Address: (VM1) 192.168.0.101
External Port: ####
Internal Port: ####
Protocol TCP

All ports to create rules for:
  80 (Caddy Reverse Proxy)
  443 (Caddy Reverse Proxy)
  8080 (cAdvisor)
  9100 (Node-Exporter)
  51821 (WireGuard)

## Make an Oracle Cloud instance to use and note its IPV4 address

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
### Start SSH
```
sudo systemctl start ssh
sudo systemctl enable ssh
sudo nano /etc/netplan/50-cloud-init.yaml
```
Add routing to the netplan yaml
```
      - to: "10.0.0.0/24"
        via: "192.168.0.20"
```

Configure Firewall
```
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 53
sudo ufw allow 443
sudo ufw allow from <Oracle Cloud IP> to any port 8080
sudo ufw allow from <Oracle Cloud IP> to any port 9100

sudo ufw enable
```

### Docker
Caddy and PiHole
Install Docker
```
sudo apt-get update && sudo apt-get upgrade -y

for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc 
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo docker network create caddy
```
Create your .env in the same directory as you will have your docker-compose and Caddyfile, this will house your secret variables
```
###Input your secrets###
##CADDY##
my_domain="site.com"
email_addr="your@email.com"
##DOCKER-COMPOSE##
vault_domain="https://vault.site.com"
homepage_domain="dashboard.site.com"
homepage_volume_directory="/home/user/homepage/"
pihole_web_pass="secret"
pihole_api_pass="super-secret"
samba_name="Data"
samba_user="user"
samba_pass="pass"
frigate_pass="pass"
```
Create your first iteration of docker-compose.yml to start Caddy and Pihole so we can create the Wireguard client. Pay special attention to how most of our services have to declare they are connecting to my-network so that pihole can act as their DNS.
```
volumes:
  # caddy_certs:
  caddy_config:
  caddy_data:
  # Actual
  actual-data:
  # Wg-easy
  etc_wireguard:
  # Pihole
  etc_pihole:

networks:
  my-network:
    name: my-network
    driver: bridge
    ipam:
      config:
        - subnet: 172.18.0.0/24
          gateway: 172.18.0.1
  caddy:
    name: caddy
    external: true

services:
  ## Caddy ##
  caddy:
    image: caddy:alpine
    restart: unless-stopped
    container_name: caddy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - /var/www/website:/var/www/website
      - caddy_data:/data
      - caddy_config:/config
    networks:
      - caddy
      - my-network
    depends_on:
      - pihole
    dns:
      - 172.18.0.66
    environment:
      - DOMAIN=${my_domain}
    command: ["/bin/sh", "-c", "caddy fmt --overwrite /etc/caddy/Caddyfile && caddy run --config /etc/caddy/Caddyfile --adapter caddyfile"]
  ## Pihole ##
  pihole:
    container_name: pihole
    image: pihole/pihole:latest
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "8081:80/tcp"
    environment:
      TZ: "America/Detroit"
      # Set a password to access the web interface. Not setting one will result in a random password being assigned
      FTLCONF_webserver_api_password: ${pihole_api_pass}
      FTLCONF_dns_listeningMode: "all"
      FTLCONF_DNSMASQ_LISTENING: "all"
      WEBPASSWORD: ${pihole_web_pass}
    volumes:
      - "./etc-pihole:/etc/pihole"
    cap_add:
      - NET_ADMIN
      - SYS_TIME
      - SYS_NICE
    restart: unless-stopped
    networks:
      my-network:
        ipv4_address: 172.18.0.66
```
Create the Caddyfile
```
# The DNS record for pve.{$DOMAIN} must point to your home's public IP address.
pve.{$DOMAIN} {
	reverse_proxy 192.168.0.100:8006 {
		transport http {
			tls
			tls_insecure_skip_verify
		}
	}
}
{$DOMAIN}, www.{$DOMAIN} {
	root * /var/www/website
	file_server
}
pihole.{$DOMAIN} {
	redir / /admin/
	reverse_proxy pihole:80
}
```

Stop systems that conflict with PiHole, pull and run your docker compose
```
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

sudo docker compose pull
sudo docker compose up -d
```

Go to pihole.your.domain and navigate to settings > Local DNS Records
Domain: <Enter domains here>
Associated IP: 192.168.0.101

Domains: @, budget, cadvisor, dashboard, home, monitor, node-exporter, pihole, prometheus, pve, vault, vpn, www

### WireGuard
Update Caddyfile by appending this to the bottom
```
{
    email {$email_addr}
}

vpn.{$DOMAIN} {
    reverse_proxy wg_easy:80
    tls internal
}
```

Update docker-compose.yml by appending this to the bottom
```
  wg-easy:
    image: ghcr.io/wg-easy/wg-easy:15
    container_name: wg-easy
    environment:
      - PORT=80
    networks:
      - caddy
      - my-network
    volumes:
      - etc_wireguard:/etc/wireguard
      - /lib/modules:/lib/modules:ro
    ports:
      - "51820:51820/udp"
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv4.conf.all.src_valid_mark=1
      - net.ipv6.conf.all.disable_ipv6=0
      - net.ipv6.conf.all.forwarding=1
      - net.ipv6.conf.default.forwarding=1
```

```
sudo apt install wireguard -y
```

WireGuard interface (vpn.domain.com) configuration in the Admin Panel
Config
	Host: <Your Router IP>
 	Port: 51820
  	Allowed IPs: 10.8.0.0/24, 192.168.0.0/24, 172.18.0.66
    DNS: 172.18.0.66
Interface
	Port: 51821
 	Device: eth0

Setup cAdvisor and Node-Exporter to monitor the VM docker containers and hardware
```
  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)($|/)'
    ports:
      - "9100:9100"
    networks:
      - caddy
      - my-network
    restart: unless-stopped

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:rw
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
    ports:
      - "8080:8080"
    networks:
      - caddy
      - my-network
    restart: unless-stopped
```
Reverse-proxy the services to be read by the cloud monitoring, add this to the Caddyfile
```
monitor.{$DOMAIN} {
    reverse_proxy {$CLOUD_IP}:3000
}
prometheus.{$DOMAIN} {
    reverse_proxy /node-exporter* node-exporter:9100
    reverse_proxy /cadvisor* cadvisor:8080
}
:80 {
    redir https://{host}{uri}
}
```

SSH into your oracle cloud instance, we're going to setup Prometheus to read data from our VM and Grafana to display it as a dashboard (https://last9.io/blog/prometheus-with-docker-compose/)
```
mkdir prometheus-monitoring
cd prometheus-monitoring

mkdir -p prometheus/rules alertmanager grafana/provisioning/{datasources,dashboards}
```
Create your docker-compose.yml file
```
volumes:
  prometheus_data: {}
  grafana_data: {}

networks:
  monitoring:
    driver: bridge

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - ./prometheus-monitoring/prometheus:/etc/prometheus
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=15d'
      - '--storage.tsdb.wal-compression'
      - '--web.enable-lifecycle'
    ports:
      - "9090:9090"
    networks:
      - monitoring
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
      - ./grafana/dashboards:/var/lib/grafana/dashboards
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    ports:
      - "3000:3000"
    networks:
      - monitoring
    restart: unless-stopped

  alertmanager:
    image: prom/alertmanager:latest
    container_name: alertmanager
    volumes:
      - ./alertmanager:/etc/alertmanager
    command:
      - '--config.file=/etc/alertmanager/config.yml'
      - '--storage.path=/alertmanager'
    ports:
      - "9093:9093"
    networks:
      - monitoring
    restart: unless-stopped
```
In your CLI
```
sudo nano prometheus-monitoring/prometheus/prometheus.yml
```
Paste in and configure with your domain
```
global:
  scrape_interval: 360s
  evaluation_interval: 15s

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

# Load rules once and periodically evaluate them
rule_files:
  - "rules/*.yml"

# Scrape configurations
scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 360s
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    scrape_interval: 300s
    static_configs:
      - targets: ['node-exporter.<yourdomain.com>']
    metric_relabel_configs:
      - source_labels: [__name__]
        regex: '^node_cpu_seconds_total|node_memory_MemTotal_bytes|node_memory_MemFree_bytes|node_disk_read_bytes_total|node_disk_written_bytes_total'
        action: keep

  - job_name: 'cadvisor'
    scrape_interval: 300s
    static_configs:
      - targets: ['cadvisor.<yourdomain.com>']
    metric_relabel_configs:
      - source_labels: [__name__]
        regex: '^container_cpu_usage_seconds_total|container_memory_usage_bytes'
        action: keep
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
