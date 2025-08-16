Step 1:
Install Proxmox and Configure

Step 2:
[Download Ubuntu Server (latest)]([url](https://ubuntu.com/download/server))

Step 3:
Upload Ubuntu Server to Proxmox under (DataCenter > PVE > local(PVE) -> ISO Images -> Upload

Step 4:
Create VM
Install WireGuard
Configure WireGuard, Router, Domain

Step 5:
Create VM
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
Create docker-compose.yaml at your chosen directory (I use /home/user/) add the code from the serve/vm2-docker/
```
sudo nano docker-compose.yaml
```
Create a Caddyfile in the same chosen directory add the code from the serve/vm2-docker/
```
sudo nano Caddyfile
```
Add .env variables to the same directory as docker-compose.yaml and Caddyfile. add the code from the serve/vm2-docker/
```
sudo nano .env
```
  Edit the .env file to your customized secrets
Make directories for your images
```
sudo mkdir homepage ##For HomePage configs
```
Stop systemd-resolved (this conflict with pihole)
```
sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
```

Network Configuration
check the IP Address of your docker VM
```
ip a
```
Log into the admin panel of your local router and port forward the IP Address you just found for Caddy
  Name: Caddy Reverse Proxy
  Device IP Address: xxx.xxx.xxx.xxx (you just found this with ip a)
  External Port: 443
  Internal Port: 443
  Protocal: TCP
Then make a second port forward rule for external/internal port 80

Log into the dashboard of your domain hosting platform (ex. NameCheap)
  Look for 'Advanced DNS' and then 'Host Records'
    Create an 'A Record' for each service you will reverse proxy with Caddy from your domain
      ex. for Actual Budget on site.com -- Type: A Record / Host: budget / Value: router.ip.address.1 / TTL: Automatic
        This will route your to the actual budget host when you search for budget.site.com on the internet
      Make one for @, budget, dashboard, home, pihole, pve, vault, www

Start Docker and Pull Images
```
##Give your docker access to pihole for DNS
sudo nano /etc/docker/daemon.json
```
Paste in
```
{
  "dns": ["8.8.8.8", "172.18.0.66", "8.8.4.4"]
}
```
save and exit

Create the directory for your website to be hosted from
```
touch /var/www/dist
sudo chown -R 1000:1000 /var/www/dist
sudo chmod -R 755 /var/www/dist
```
Move your site files to be hosted in there
```
sudo docker compose pull
sudo docker compose up caddy -d
sudo docker compose up pihole -d
```
Log into the pihole admin panel (http://your.vm.ip.xxx:8081/admin)
  Use the password you set in your .env secrets
  Browse to System > Settings > Local DNS
    Add a local DNS
      Domain: pihole.your-domain.com
      IP: your.vm.ip.xxx
    Add local DNS for budget, dashboard, home, pihole, pve, vault
Replace the Caddyfile with its full contents (found in GitHub at serve/vm2-docker/Caddyfile)

Restart all the Docker containers with the new Caddyfile
```
sudo docker compose down
sudo docker compose up -d
```

Now we configure

UFW Rules
```
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 53
sudo ufw allow 443
sudo ufw allow from <Oracle Clouse IP> to any port 8080
sudo ufw allow from <Oracle Clouse IP> to any port 9100

sudo ufw enable
```

Port List:
80 - Caddy
53 - Pihole
443 - Caddy
445 - Samba
8081 - Pihole
8000 - Vaultwarden
8080 - Cadvisor
8554 - Frigate
8555 - Frigate
8971 - Frigate
9100 - node-exporter
