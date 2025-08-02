# Read more about SSH config files: https://linux.die.net/man/5/ssh_config
Host UbuntuServer
    HostName 192.###.#.##
    User <user>

Host ubuntu-server-direct
    HostName vpn.<name>.org
    Port <####>
    User <user>
    IdentityFile ~/.ssh/<id_rsa_yourkey>

Steps to Generate SSH Keys on Windows (using Git Bash or WSL/PowerShell):

Open a Terminal:

Git Bash: If you have Git installed, you'll have Git Bash. This is often the easiest on Windows.

WSL (Windows Subsystem for Linux): If you're using WSL, open your Linux distribution.

PowerShell: You can also do this directly in a modern PowerShell window (Windows 10/11 comes with OpenSSH client).

Generate the Key Pair:
In your chosen terminal, run the following command:

Bash

ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_ubuntu_server -C "your_username@your_machine_name"
-t ed25519: Specifies the type of key. ed25519 is a modern, highly recommended, and very secure algorithm. (Historically, rsa was common, but ed25519 is preferred now).

-f ~/.ssh/id_ed25519_ubuntu_server: This sets the filename and path for your private key.

~/.ssh/ is the standard location for SSH keys on Linux/macOS, and PowerShell/Git Bash on Windows will map this to C:\Users\YourUsername\.ssh\.

id_ed25519_ubuntu_server is a custom name I've given it. It's a good practice to name keys specifically if you have many. You can use id_ed25519 if this is your primary key.

-C "your_username@your_machine_name": Adds a comment to the public key (useful for identifying it later).

Set a Passphrase (Highly Recommended):
The command will prompt you:

Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Always set a strong passphrase. This encrypts your private key file on your local machine, so even if someone gets the file, they can't use it without the passphrase. VS Code (and other SSH clients) will prompt you for this passphrase when you first connect in a session.

Resulting Files:
After generation, you will find two files in C:\Users\YourUsername\.ssh\ (or ~/.ssh/ in your terminal):

id_ed25519_ubuntu_server (This is your private key - keep it secret!)

id_ed25519_ubuntu_server.pub (This is your public key - you'll copy its contents to the Ubuntu server)

What to Change in IdentityFile
Once you've generated your keys:

Copy Public Key to Ubuntu Server:

On your Windows desktop, copy the content of the public key file (id_ed25519_ubuntu_server.pub). You can open it with Notepad.

SSH into your Ubuntu server (you might need to use a password for this first login if you haven't set up keys yet).

On the Ubuntu server, ensure the .ssh directory exists for your user:

Bash

mkdir -p ~/.ssh
chmod 700 ~/.ssh # Set correct permissions
Open (or create) the authorized_keys file for your user:

Bash

nano ~/.ssh/authorized_keys
Paste the entire content of your id_ed25519_ubuntu_server.pub file into authorized_keys on a single line.

Save and exit (Ctrl+X, Y, Enter).

Set correct permissions for authorized_keys:

Bash

chmod 600 ~/.ssh/authorized_keys
Update VS Code SSH Config:

Open your VS Code SSH config file (Remote-SSH: Open Configuration File...).

Modify the IdentityFile line to point to the private key file you just generated on your Windows desktop.

Code snippet

Host ubuntu-server
    HostName 10.0.0.1
    User your_ssh_username
    IdentityFile ~/.ssh/id_ed25519_ubuntu_server # <-- This is the path to your private key
Save the config file.
