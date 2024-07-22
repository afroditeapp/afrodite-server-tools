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

sudo cryptsetup luksOpen hello.txt app-encrypted-data-mapper
sudo cryptsetup luksClose hello.txt app-encrypted-data-mapper
sudo mkfs.ext4 /dev/mapper/app-encrypted-data-mapper
mkdir encrypted-fs
sudo mount /dev/mapper/app-encrypted-data-mapper encrypted-fs

cd encrypted-fs
sudo mkdir test
sudo chown ubuntu:ubuntu test/

sudo umount /dev/mapper/app-encrypted-data-mapper

### Make encrypted fs larger

sudo umount /app-secure-storage
sudo cryptsetup luksClose encrypted-filesystem.data

sudo truncate --size=+1G encrypted-filesystem.data

sudo cryptsetup luksOpen encrypted-filesystem.data app-encrypted-data-mapper
or
sudo cryptsetup --key-file - luksOpen encrypted-filesystem.data app-encrypted-data-mapper <<< password

sudo e2fsck -f /dev/mapper/app-encrypted-data-mapper
sudo resize2fs /dev/mapper/app-encrypted-data-mapper


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
sudo apt install ansible


# Check setup environment instructions
sudo bash -eu setup-environment.sh
# Override iptables rules and run the script again with reqired arguments
sudo bash -eu setup-environment.sh TODO

curl https://sh.rustup.rs -sSf | sh -s -- -y
source "$HOME/.cargo/env"
sudo apt install build-essential libssl-dev pkg-config
```

Mount app-manager repository using multipass.

Create script:

```
#!/bin/bash -eux

cd
mkdir -p src
rsync -av --delete --progress --exclude="/target" /APP-MANAGER-SRC/ ~/src

cd ~/src
cargo build --bin app-manager --release
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

## Recommended development style

1. Install multipass

2. Create VM

3. Mount projects

4. Create scripts to VM for copying projects from host machine to VM

```
# The exclude for 'target' directory exists to avoid copying Rust related
# files if the project is made with Rust.
rsync -ax --exclude target --exclude .git /host-machine-project-path ~/
```
