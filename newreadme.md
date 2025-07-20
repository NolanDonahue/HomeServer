<img width="700" height="200" alt="Another_Juvenile_Home_Server" src="https://github.com/user-attachments/assets/9dacd65e-2d37-4f58-95a1-5ea009c7ce2b" />

Install Proxmox on your Home Server
https://www.proxmox.com/en/downloads
Use Rufus to create a bootable flashdrive with the Proxmox ISO
https://rufus.ie/en/

Flash the Proxmox OS to your server from the boot menu
Install Proxmox with default configurations paying special attention to the IP address on your WAN

Download the Ubuntu Server ISO to your host server that you wish to SSH from
https://ubuntu.com/download/server

Open Proxmox on your remote connection via the instructions in the CLI

Install the ISO you downloaded under Datacenter>pve>local(pve) under ISO template

(If your server is a laptop set the lid to not put the system to sleep via: [sudo nano logind.conf] then set HandleLidSwitch:ignore)

Create a VM to use as a template
Core/Socket: 1
OS: Ubuntu Server
Ram: 2048

Install Ubuntu Server and during installation install open-ssh with your GitHub SSH Key
https://docs.github.com/en/authentication/connecting-to-github-with-ssh

SSH into your machine through VSCode with your GitHub credentials 
https://code.visualstudio.com/docs/remote/ssh

Install Docker and Docker Compose
https://docs.docker.com/engine/install/ubuntu/

With Docker and Docker Compose installed you can add the docker containers as necessary and run them with [sudo docker compose up -d]
  edit compose file with [sudo nano /docker/docker-compose.yml]



Samba File Share Container
  https://github.com/dockur/samba
  Add the compose iformation to your docker-compose.yml and then run it with sudo docker compose up -d

Wireguard
  https://github.com/wg-easy/wg-easy

  AI Instructions:
Configure Dynamic DNS on Namecheap (Website)

Log in to your Namecheap account.

Go to your Domain List, click Manage next to nolandonahue.org.

Navigate to the Advanced DNS tab.

Enable Dynamic DNS: In the Dynamic DNS section, toggle it to Enabled. Make note of the Dynamic DNS Password displayed; this is unique for DDNS.

Add an A + Dynamic DNS Record:

In the Host Records section, click Add New Record.

Type: Select A + Dynamic DNS Record.

Host: Enter vpn.

Value: Enter a dummy IP address like 127.0.0.1 (this will be updated automatically).

TTL: Set to Automatic or 1 Min.

Click the checkmark/save icon to save the record.

Configure Router Port Forwarding (TP-Link AX55)

Log in to your TP-Link AX55 router's administration interface.

Navigate to the Port Forwarding settings (often found under Advanced > NAT Forwarding > Port Forwarding or similar).

Create a new port forwarding rule:

Service Port/External Port: 51821

Internal Port: 51821

Internal IP Address: Enter the static internal IP address of your Ubuntu Server VM (e.g., 192.168.1.100).

Protocol: Select UDP.

Status: Ensure it's Enabled.

Save the changes on your router.

Prepare Ubuntu Server VM

SSH into your Ubuntu Server VM.

Update System:

Bash

sudo apt update && sudo apt upgrade -y
Install WireGuard:

Bash

sudo apt install wireguard -y
Enable IP Forwarding:

Open /etc/sysctl.conf for editing:

Bash

sudo nano /etc/sysctl.conf
Uncomment (remove #) or add the line:

net.ipv4.ip_forward=1
Save and exit (Ctrl+X, Y, Enter).

Apply changes immediately:

Bash

sudo sysctl -p
Generate WireGuard Keys:

Switch to root and set permissions:

Bash

sudo -i
cd /etc/wireguard/
umask 077
Generate the server's private key:

Bash

wg genkey | tee privatekey
Generate the server's public key:

Bash

cat privatekey | wg pubkey | tee publickey
Copy the contents of privatekey and publickey to a secure temporary location, as you'll need them.

Exit root: exit

Configure WireGuard Server (wg0.conf)

Open the WireGuard configuration file:

Bash

sudo nano /etc/wireguard/wg0.conf
Paste the following, replacing <YOUR_SERVER_PRIVATE_KEY> with your server's private key from step 3, and <YOUR_VM_NETWORK_INTERFACE> with your VM's actual interface name (e.g., ens18):

Ini, TOML

[Interface]
PrivateKey = <YOUR_SERVER_PRIVATE_KEY>
Address = 10.0.0.1/24       # VPN server's IP within the tunnel
ListenPort = 51821          # Must match the port forwarded in your router
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o <YOUR_VM_NETWORK_INTERFACE> -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o <YOUR_VM_NETWORK_INTERFACE> -j MASQUERADE
Save and exit (Ctrl+X, Y, Enter).

Start WireGuard Server

Enable WireGuard to start on boot:

Bash

sudo systemctl enable wg-quick@wg0
Start the WireGuard service:

Bash

sudo systemctl start wg-quick@wg0
Verify it's running:

Bash

systemctl status wg-quick@wg0
It should show Active: active (running).

Configure Dynamic DNS Client (ddclient)

Install ddclient. This will likely launch a configuration wizard:

Bash

sudo apt install ddclient -y
Follow the ddclient GUI prompts:

Dynamic DNS service provider: Select namecheap.com.

Hostname: Enter your full domain name, e.g., nolandonahue.org.

Username: Enter your full domain name again, e.g., nolandonahue.org.

Password: Enter the Dynamic DNS Password you noted from Namecheap's website (from step 1).

Hosts to update (comma separated): Enter vpn.

DNS Interface: Choose web.

Web IP check page (URL): Leave as default (checkip.dyndns.org/).

Check IP Skip Text: Leave as default (IP Address).

Run as daemon?: Select Yes.

Update interval: Keep default (300 seconds).

Verify/Adjust ddclient.conf (if needed):

Bash

sudo nano /etc/ddclient.conf
Ensure it looks like this (values should be filled by the wizard):

Ini, TOML

daemon=300
protocol=namecheap
ssl=yes
use=web, web=checkip.dyndns.org/, web-skip='IP Address'
server=dynamicdns.park-your-domain.com
login=nolandonahue.org
password=<YOUR_NAMECHEAP_DDNS_PASSWORD>
vpn.nolandonahue.org
Save and exit.

Start and enable ddclient:

Bash

sudo systemctl enable ddclient
sudo systemctl start ddclient
Verify ddclient is updating by checking Namecheap's Advanced DNS for vpn.nolandonahue.org after a few minutes, or sudo journalctl -u ddclient -f on the VM for success messages.

Generate WireGuard Client Configuration (on Ubuntu VM)

Generate Client Keys: For your Windows Desktop (example client):

Bash

wg genkey | tee client_windows_privatekey
cat client_windows_privatekey | wg pubkey | tee client_windows_publickey
Copy the contents of client_windows_privatekey and client_windows_publickey.

Add Client to Server Configuration:

Open /etc/wireguard/wg0.conf again:

Bash

sudo nano /etc/wireguard/wg0.conf
Append the [Peer] section, replacing <CLIENT_WINDOWS_PUBLIC_KEY> with the public key you just generated and assigning a unique IP (e.g., 10.0.0.2/32):

Ini, TOML

# Client: Windows Desktop
[Peer]
PublicKey = <CLIENT_WINDOWS_PUBLIC_KEY>
AllowedIPs = 10.0.0.2/32
Save and exit.

Restart WireGuard service to load new peer:

Bash

sudo systemctl restart wg-quick@wg0
Create Client Configuration File:

Create a file for your client (e.g., windows_desktop.conf):

Bash

nano windows_desktop.conf
Paste the following, replacing placeholders with your client's private key, your server's public key (from /etc/wireguard/publickey on the VM), and your domain/port:

Ini, TOML

[Interface]
PrivateKey = <CLIENT_WINDOWS_PRIVATE_KEY>
Address = 10.0.0.2/32
DNS = 1.1.1.1, 8.8.8.8 # Or your router's IP if you want local DNS resolution

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
Endpoint = vpn.nolandonahue.org:51821
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
Save and exit.

Transfer Client Configuration & Connect (Windows Desktop)

Transfer windows_desktop.conf to your Windows 11 Desktop (e.g., via SCP, SFTP, or simply copy-pasting the content).

Download and install WireGuard for Windows from wireguard.com/install.

Open the WireGuard application.

Click Import tunnel(s) from file and select windows_desktop.conf.

Name the tunnel.

Click Activate to connect.

Testing and Verification:
From your Windows Desktop (with VPN activated):

Verify Public IP: Go to whatismyip.com. It should now show your home's public IP address.

Ping Server: Open PowerShell/CMD and ping 10.0.0.1 (your VPN server's internal IP).

Access Samba Share: Access your share via its VPN IP: \\10.0.0.1\yoursharename.

SSH to Server: SSH to your VM using its VPN IP (10.0.0.1) or its internal LAN IP (192.168.x.x).

Once this is complete it will break your connection with local servers and you need to edit the tunnel and change Allowed IPs
AllowedIPs = 10.0.0.0/24, 192.168.1.0/24, 10.0.0.1/32 # Routes for VPN tunnel, home network, and VPN server's specific internal IP
