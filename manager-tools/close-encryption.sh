#!/bin/bash -eu

# Run as root

umount /app-secure-storage
cryptsetup luksClose app-encrypted-data-mapper
