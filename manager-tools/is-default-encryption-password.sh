#!/bin/bash -eu

ENCRYPTED_FILE="/app-encrypted-filesystem/encrypted-filesystem.data"
MAPPER_FILE="/dev/mapper/app-encrypted-data-mapper"

# Use this script like ./is-default-encryption-password.sh < key.txt
# Also run as root

cryptsetup --test-passphrase --key-file - luksOpen "$ENCRYPTED_FILE" <<< "password"
