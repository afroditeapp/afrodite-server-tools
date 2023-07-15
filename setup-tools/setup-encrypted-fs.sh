#!/bin/bash -eu

ENCRYPTED_FILE="/app-encrypted-filesystem/encrypted-filesystem.data"
MAPPER_FILE="/dev/mapper/app-encrypted-data-mapper"

if [ -f "$ENCRYPTED_FILE" ]; then
    echo "Encrypted file is already created"
    exit 1
fi

mkdir /app-encrypted-filesystem
fallocate -l 2G "$ENCRYPTED_FILE"
# App manager will change default password
cryptsetup --key-file - luksFormat "$ENCRYPTED_FILE" <<< "password"

cryptsetup --key-file - luksOpen "$ENCRYPTED_FILE" app-encrypted-data-mapper <<< "password"
sudo mkfs.ext4 /dev/mapper/app-encrypted-data-mapper

mkdir /app-secure-storage
mount "$MAPPER_FILE" /app-secure-storage

mkdir /app-secure-storage/app
chown app:app /app-secure-storage/app

mkdir /app-secure-storage/app/binaries
chown app:app /app-secure-storage/app/binaries

mkdir /app-secure-storage/app/backend-working-dir
chown app:app /app-secure-storage/app/backend-working-dir
