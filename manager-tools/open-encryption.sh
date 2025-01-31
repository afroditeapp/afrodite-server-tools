#!/bin/bash -eu

ENCRYPTED_FILE="/afrodite-encrypted-filesystem/encrypted-filesystem.data"
MAPPER_FILE="/dev/mapper/afrodite-encrypted-data-mapper"

# Use this script like ./cryptsetup-open-luks.sh < key.txt
# Also run as root

cryptsetup --key-file - luksOpen "$ENCRYPTED_FILE" afrodite-encrypted-data-mapper
mount "$MAPPER_FILE" /afrodite-secure-storage
