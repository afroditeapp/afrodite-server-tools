#!/bin/bash -eu

ENCRYPTED_FILE="/app-encrypted-filesystem/encrypted-filesystem.data"
MAPPER_FILE="/dev/mapper/app-encrypted-data-mapper"

# Use this script like ./cryptsetup-open-luks.sh < key.txt
# Also run as root

cryptsetup --key-file - luksOpen "$ENCRYPTED_FILE" app-encrypted-data-mapper
mount "$MAPPER_FILE" /app-secure-storage
