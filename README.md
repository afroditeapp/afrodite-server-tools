# afrodite-server-tools
Scripts for setuping a new Ubuntu VM for
[afrodite-backend](https://github.com/jutuon/afrodite-backend).

## Python script dependencies on macOS

```bash
brew install python3
pip3 install requests
```

## LUKS

https://askubuntu.com/questions/58935/how-do-i-create-an-encrypted-filesystem-inside-a-file

sudo needed for initial LUKS creation because of bug
https://bugs.launchpad.net/ubuntu/+source/cryptsetup/+bug/1872056

TODO: Remove the following commands once secure storage expanding support is
added to the manager mode.

```bash
fallocate -l 128M /path/to/file

sudo cryptsetup -y luksFormat hello.txt

cryptsetup luksDump hello.txt

sudo cryptsetup luksOpen hello.txt afrodite-encrypted-data-mapper
sudo cryptsetup luksClose hello.txt afrodite-encrypted-data-mapper
sudo mkfs.ext4 /dev/mapper/afrodite-encrypted-data-mapper
mkdir encrypted-fs
sudo mount /dev/mapper/afrodite-encrypted-data-mapper encrypted-fs

cd encrypted-fs
sudo mkdir test
sudo chown ubuntu:ubuntu test/

sudo umount /dev/mapper/afrodite-encrypted-data-mapper
```

### Make encrypted fs larger

```bash
sudo umount /afrodite-secure-storage
sudo cryptsetup luksClose encrypted-filesystem.data

sudo truncate --size=+1G encrypted-filesystem.data

sudo cryptsetup luksOpen encrypted-filesystem.data afrodite-encrypted-data-mapper
# or
sudo cryptsetup --key-file - luksOpen encrypted-filesystem.data afrodite-encrypted-data-mapper <<< password

sudo e2fsck -f /dev/mapper/afrodite-encrypted-data-mapper
sudo resize2fs /dev/mapper/afrodite-encrypted-data-mapper
```

## Fail2Ban

Check ban status:

```bash
sudo fail2ban-client status sshd
```

## Afrodite backend manager mode local development with multipass

1. Create new multipass VM.

2. On VM, do initial setup with
[initial_server_setup.md](./docs/initial_server_setup.md)
instructions.

3. On VM, install required dependencies for building
[afrodite-backend](https://github.com/jutuon/afrodite-backend).

4. On host, mount `afrodite-backend` repository to VM.

5. On VM, save the following script to a file.
   Also replace `AFRODITE-BACKEND-SRC` with VM path to the repository.

```bash
#!/bin/bash -eux

cd
mkdir -p src
rsync -av --delete --progress --exclude "/target" --exclude ".git" /AFRODITE-BACKEND-SRC/ ~/src

cd ~/src
cargo build --bin afrodite-backend --release
sudo systemctl stop afrodite-manager
sudo cp target/release/afrodite-backend /home/afrodite
sudo chown afrodite:afrodite /home/afrodite/afrodite-backend
sudo systemctl restart afrodite-manager
sudo journalctl -u afrodite-manager.service -b -e -f
```

   Optionally save script for editing config:

```bash
#!/bin/bash -eux

sudo -u afrodite vim /home/afrodite/manager_config.toml
```

6. Edit code on host and run the first script on VM when code
   should be tested.

## License

MIT License or Apache License 2.0
