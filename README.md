# app-server-tools
Scripts which will be downloaded when new app VPS instance is created

## Building on MacOS

Python script:

brew install python3
pip3 install requests


## LUKS

https://askubuntu.com/questions/58935/how-do-i-create-an-encrypted-filesystem-inside-a-file

sudo needed for initial LUKS creation because of bug
https://bugs.launchpad.net/ubuntu/+source/cryptsetup/+bug/1872056


fallocate -l 128M /path/to/file

sudo cryptsetup -y luksFormat hello.txt


cryptsetup luksDump hello.txt

sudo cryptsetup luksOpen hello.txt app-encrypted-data
sudo cryptsetup luksClose hello.txt app-encrypted-data
sudo mkfs.ext4 /dev/mapper/app-encrypted-data
mkdir encrypted-fs
sudo mount /dev/mapper/app-encrypted-data encrypted-fs

cd encrypted-fs
sudo mkdir test
sudo chown ubuntu:ubuntu test/

sudo umount /dev/mapper/app-encrypted-data

## Fail2Ban

sudo apt install fail2ban
cd /etc/fail2ban
cp jail.conf jail.local


Edit file:
[sshd]
enable=true

Also perhaps time

findtime = 500h
maxretry = 2

systemctl enable fail2ban
systemctl start fail2ban

Check ban status:

sudo fail2ban-client status sshd


## Check cloud init files

Following command was in systemd logs:
sudo cloud-init schema --system

Validate:
cloud-init schema --config-file bob.txt

## Multipass

Don't use cloud init. Instead:

```
sudo adduser app
sudo adduser app_admin_user_with_ssh
sudo usermod -aG sudo app_admin_user_with_ssh
sudo apt install python3 python3-requests ipset git fail2ban
curl https://sh.rustup.rs -sSf | sh -s -- -y
source "$HOME/.cargo/env"
sudo apt install build-essential libssl-dev pkg-config
```

Follow initial_server_setup.md but do not configure iptables.

Mount app-manager repository using multipass.

Install Rust.

Create script:

```
#!/bin/bash -eux

cd
mkdir -p src
rsync -av --delete --progress --exclude="/target" --exclude="/.git" /APP-MANAGER-SRC/ ~/src

cd ~/src
cargo build --release
sudo -u app mkdir -p /home/app/binaries
sudo -u app mkdir -p /home/app/manager-working-dir
sudo systemctl stop app-manager
sudo cp target/release/app-manager /home/app/binaries
sudo chown app:app /home/app/binaries/app-manager
sudo systemctl restart app-manager
sudo journalctl -u app-manager.service -b -e -f
```

And build and start manager using that script.

Script for editing config:

```
#!/bin/bash -eux

sudo -u app vim /home/app/manager-working-dir/manager_config.toml
```
