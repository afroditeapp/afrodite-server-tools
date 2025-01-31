#!/bin/bash -eu

# This should be run as user afrodite

backend_download_key_path="/afrodite-secure-storage/afrodite/.ssh/afrodite-backend-download.key"

echo "Checking required packages"
echo "Run"
echo $'\tsudo apt install build-essential libssl-dev pkg-config'
echo "if needed"
echo ""

dpkg -s build-essential libssl-dev pkg-config > /dev/null

if [ $? -ne 0 ]; then
    echo "Error: required packages are missing"
    exit 1
fi

echo "Required packages are installed"

if [ "$USER" != "afrodite" ]; then
    echo "Not correct user"
    echo ""
    echo "Usage: sudo -u afrodite bash -eux bootsrap-build-server.sh"
    exit 1
fi

if [ ! -f "$backend_download_key_path" ]; then
    echo "Error: $backend_download_key_path does not exist"
    exit 1
fi

chmod 600 "$backend_download_key_path"

# Install Rust if not installed
if [ ! -f "$HOME/.cargo/env" ]; then
    curl https://sh.rustup.rs -sSf | sh -s -- -y
fi
source "$HOME/.cargo/env"

# Move to secure home dir
cd /afrodite-secure-storage/afrodite

mkdir -p tmp
cd tmp
if [ ! -d "afrodite-manager" ]; then
    git clone --depth 1 https://github.com/jutuon/afrodite-manager
fi
cd afrodite-manager
git pull origin main
cargo build --release

mkdir -p /home/afrodite/binaries
if [ -f "/home/afrodite/binaries/afrodite-manager" ]; then
    # Remove old binary as copying over it will not work if it is running
    echo "Removing old binary"
    rm /home/afrodite/binaries/afrodite-manager
fi
cp target/release/afrodite-manager /home/afrodite/binaries/afrodite-manager
chmod u+x /home/afrodite/binaries/afrodite-manager
mkdir -p /home/afrodite/manager-working-dir

echo "Afrodite manager is now installed to /home/afrodite/binaries/afrodite-manager"
echo "Afrodite manager service working directory: /home/afrodite/manager-working-dir"
echo "Start command: sudo systemctl start afrodite-manager.service"
echo "Read logs command: sudo journalctl --follow -u afrodite-manager.service"
