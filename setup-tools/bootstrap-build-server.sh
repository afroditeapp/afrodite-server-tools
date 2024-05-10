#!/bin/bash -eu

# This should be run as user app

backend_download_key_path="/app-secure-storage/app/.ssh/app-backend-download.key"

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

if [ "$USER" != "app" ]; then
    echo "Not correct user"
    echo ""
    echo "Usage: sudo -u app bash -eux bootsrap-build-server.sh"
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
cd /app-secure-storage/app

mkdir -p tmp
cd tmp
if [ ! -d "app-manager" ]; then
    git clone --depth 1 https://github.com/jutuon/app-manager
fi
cd app-manager
cargo build --release

mkdir -p /home/app/binaries
cp target/release/app-manager /home/app/binaries/app-manager
chmod u+x /home/app/binaries/app-manager
mkdir -p /home/app/manager-working-dir

echo "App manager is now installed to /home/app/binaries/app-manager"
echo "App manager service working directory: /home/app/manager-working-dir"
echo "Start command: sudo systemctl start app-manager.service"
echo "Read logs command: sudo journalctl --follow -u app-manager.service"
