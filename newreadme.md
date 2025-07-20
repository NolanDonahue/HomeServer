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
