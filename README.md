# HomeServer
Project for creating a home server

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
  https://docs.docker.com/engine/install/ubuntu/
