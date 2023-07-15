#!/bin/bash -eu

# This should be run as user app
if [ "$USER" != "app" ]; then
    echo "Not correct user"
    exit 1
fi

chmod 600 /app-secure-storage/app/.ssh/app-manager-download.key
chmod 600 /app-secure-storage/app/.ssh/app-backend-download.key

# Move to secure home dir
cd /app-secure-storage/app

curl https://sh.rustup.rs -sSf | sh -s -- -y
source "$HOME/.cargo/env"

# Might not be needed
cd /app-secure-storage/app

mkdir sources
cd sources
git clone -c "core.sshCommand=ssh -i /app-secure-storage/app/.ssh/app-manager-download.key" --depth 1 git@github.com:jutuon/app-manager.git
cd app-manager
cargo build --release

mkdir -p /home/app/binaries
cp target/release/app-manager /home/app/binaries/app-manager
mkdir -p /home/app/manager-working-dir
