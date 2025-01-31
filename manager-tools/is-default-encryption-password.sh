#!/bin/bash -eu

ENCRYPTED_FILE="/afrodite-encrypted-filesystem/encrypted-filesystem.data"
MAPPER_FILE="/dev/mapper/afrodite-encrypted-data-mapper"

# Use this script like ./is-default-encryption-password.sh < key.txt
# Also run as root

cryptsetup --test-passphrase --key-file - luksOpen "$ENCRYPTED_FILE" <<< "password"
