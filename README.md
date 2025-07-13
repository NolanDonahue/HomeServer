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
-Install Net-Applcations
-Run ifconfig and not IP Address
--ON MASTER COMPUTER
-Open CMD Prompt
-Run ssh-config and install your public key under a .ssh file in your user
-type $env:USERPROFILE\.ssh\id_rsa.pub | ssh <###USER###>@<###IP ADDRESS###> "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
  Replace <###USER###> and <###IP ADDRESS###>

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
    run the file
Build a VM to house the samba container
  Install -  https://www.cherryservers.com/blog/install-kvm-ubuntu
  Install - https://www.youtube.com/watch?v=KCLaVlwfOHM
  Virsh create a VM - https://www.thegeekstuff.com/2014/10/linux-kvm-create-guest-vm/
    sudo virt-install \
  --name testVM \
  --ram 2048 \
  --vcpus 2 \
  --disk path=/var/lib/libvirt/images/testVM.qcow2,size=50,format=qcow2 \
  --network bridge=br0 \
  --location /home/nolan/share/ubuntu-24.04.2-live-server-amd64.iso \
  --os-variant ubuntu24.04 \
  --console pty,target_type=serial \
  --extra-args "console=ttyS0,115200n8" \
  --noautoconsole \
  --virt-type kvm

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

OpenVPN - Using SAMBA fileshare to share the configuration file
  [https://www.youtube.com/watch?v=12ccTRzLwAc](https://documentation.ubuntu.com/server/how-to/security/install-openvpn/)
  sudo -s
    Used to navigate to easy-rsa in the /etc/openvpn because it is a restricted directory
  
