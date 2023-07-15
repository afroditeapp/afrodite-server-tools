#!/bin/bash

ENCRYPTED_FILE="/app-encrypted-filesystem/encrypted-filesystem.data"

# Use this script like ./change-encryption-password.sh < key.txt
# Also run as root

mkdir -p /mnt/keyfs
mount -t tmpfs -o size=10M tmpfs /mnt/keyfs
cat > /mnt/keyfs/new-key

cryptsetup --key-file - luksChangeKey "$ENCRYPTED_FILE" /mnt/keyfs/new-key <<< "password"

result_of_cryptsetup=$?

shred -u /mnt/keyfs/new-key

if [ $? -eq 0 ]; then
    echo "Erasing key file succeeded"
else
    echo "Erase of key file failed"
fi

umount /mnt/keyfs

if [ $? -eq 0 ]; then
    echo "Unmounting key tmpfs succeeded"
else
    echo "Unmounting key tmpfs failed"
fi

exit $result_of_cryptsetup
