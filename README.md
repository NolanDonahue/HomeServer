# HomeServer
Project for creating a home server

List of Ideas: https://github.com/awesome-selfhosted/awesome-selfhosted?tab=readme-ov-file#analytics

Hardware
Test Bench: ACER Swift 5
Home Server: Dell Vostro 3670

1. Install Ubuntu Server and Establish SSH

1. Ubuntu Server and SSH
-Download the Ubuntu Server ISO
  -Download the Rufus standalone bootable usb configurator
   -Use Rufus to make the bootable Ubuntu Server OS with a thumb drive
-Enter the BIOS of the server and set the thumbdrive to be the first to execute, install Ubuntu Server and download OpenSSH
-Open SSH
--ON SLAVE COMPUTER
-sudo systemctl enable ssh
-sudo systemctl start ssh
-ip a (find IP address)
--ON MASTER COMPUTER
**DEPRECATED BECUSE VSCODE IS BETTER**
-Open CMD Prompt
-Run ssh-config and install your public key under a .ssh file in your user
-type $env:USERPROFILE\.ssh\id_rsa.pub | ssh <###USER###>@<###IP ADDRESS###> "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
  delete known hosts if using a new image on an old ip
  Replace <###USER###> and <###IP ADDRESS###>

#SSH VIA GITHUB/VSCODE#
Generate a public SSH key and upload it to your github account
On flashing Ubuntu Server connect your GitHub SSH key for use
Enable ssh with systemctl
Open VSCode and install the remote connections extension
Open Remote Connections and Connect to your host
Run bootup script from VSCode

Using Restic to backup the testbench for easier restoration of botched ideas
https://www.youtube.com/watch?v=HixCvh8I4LA
-sudo apt install restic
-sudo mkdir /home/user/backup-repository
-sudo restic init -r /home/user/backup-repository/
  Save password for later use
-sudo restic -r /home/user/backup-respository/ backup / --exclude="/home/nolan/backup-repository/"
  Create a backup of the entire directory excluding other backups
 -sudo restic -r /home/user/backup-repository/ snapshots
   View prior backups
  -sudo restic -r /home/user/backups-repository/ restore latest --target /home/user/directory to be restored
  -sudo restic -r /home/user/backup-repository forget latest

Learning the basics of Docker

-Install Docker
  https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
-The basics
  https://nerdyarticles.com/docker-101/
Bridge vs Host Network - Starting with bridge may try to implement host for the file sharing portion
Perisistent storagE? Is it needed for all the apps? Probably for most
  Versatile option with named volumes for file sharing
.env - key information reused in all containers
  more secure information
  Never put into a repository
Samba via Docker
  https://github.com/dockur/samba
  docker compose up
    run the file with docker run -d to keep your terminal free

##DEPRECEATED because is really hard##
Build a VM to house the samba container
  Install -  https://www.cherryservers.com/blog/install-kvm-ubuntu
  Install - https://www.youtube.com/watch?v=KCLaVlwfOHM
  Virsh create a VM - https://www.thegeekstuff.com/2014/10/linux-kvm-create-guest-vm/
    sudo virt-install \
    --name testVM \
    --ram 2048 \
    --vcpus 2 \
    --disk path=/var/lib/libvirt/images/testVM.qcow2,size=50,format=qcow2 \
    --network network=default \
    --location /var/lib/libvirt/boot/ubuntu-24.04.2-live-server-amd64.iso \
    --os-variant ubuntu24.04 \
    --console pty,target_type=serial \
    --graphics none
  Virsh interact with the VM
    virsh list --all [show all VMs]
    virsh start VM [start the VM]
    

Check Battery Life on Laptop
in the bottom of .bashrc (using nano) add in this alias
alias bat='upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E "time full|percentage"'

Fileserver - SMB for interfacing with Windows Computers and Android Phones
  https://www.youtube.com/watch?v=y7esIzzkzSE
    THIS VIDEO WORKS ^^^
    THIS VIDEO DOESNT I COULDNT FIX IT \/
  https://www.youtube.com/watch?v=2YQoAWQY6Uo
  Problem: Permissions to be able to interface with the fileshare from a windows computer not working
    Solution: You can't add a user... You have to create a group and add the user to the group that is whitelisted
    sudo groupadd editors
    sudo usermod -a -G editors john
    sudo chown -R root:editors /path/to/your/share
    sudo chmod -R 2770 /path/to/your/share
  Access fileshare \\your.ip.here.123\

OpenVPN - Using SAMBA fileshare to share the configuration file
  [https://www.youtube.com/watch?v=12ccTRzLwAc](https://documentation.ubuntu.com/server/how-to/security/install-openvpn/)
  sudo -s
    Used to navigate to easy-rsa in the /etc/openvpn because it is a restricted directory
  
-------------KVM is dumb switching to proxmox----------------------
https://www.proxmox.com/en/products/proxmox-virtual-environment/get-started
https://www.youtube.com/watch?v=5j0Zb6x_hOk
  KVM does not like wifi... just use ethernet or it is miserable
Proxmox breaks when on a community network, must wait to use until I have my own router/modem

----
Bypass CGNAT to port forward your server
https://www.youtube.com/watch?v=7TOwr1Hs9fk&t=28s
