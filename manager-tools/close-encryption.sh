#!/bin/bash -eu

# Run as root

umount /afrodite-secure-storage
cryptsetup luksClose afrodite-encrypted-data-mapper
