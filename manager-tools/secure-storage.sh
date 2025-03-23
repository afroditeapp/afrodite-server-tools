#!/bin/bash -u

DEFAULT_STORAGE_DIR="/afrodite-secure-storage"
DEFAULT_STORAGE_PASSWORD="password"

CMD_EXTEND_SIZE_AND_OPEN="extend-size-and-open"
CMD_CLOSE="close"
CMD_IS_DEFAULT_PASSWORD="is-default-password"
CMD_CHANGE_DEFAULT_PASSWORD="change-default-password"

function print_help_and_quit() {
    echo "Usage: sudo bash -u secure-storage.sh COMMAND STORAGE_DIR [STORAGE_SIZE_IN_BYTES]"
    echo "Available commands:"
    echo "  $CMD_EXTEND_SIZE_AND_OPEN - Password is read from standard input, required state: closed"
    echo "  $CMD_CLOSE"
    echo "  $CMD_IS_DEFAULT_PASSWORD - Exits with value 0 when the password is the default password, required state: closed"
    echo "  $CMD_CHANGE_DEFAULT_PASSWORD - Password is read from standard input, required state: closed"
    echo "Available storage directories: $DEFAULT_STORAGE_DIR"
    exit 1
}

### Input: $1 = STORAGE_DIR
function setup_global_variables() {
    if [ "$1" == "$DEFAULT_STORAGE_DIR" ]; then
        g_storage_dir="$1"
        g_encrypted_file="/afrodite-encrypted-filesystem/encrypted-filesystem.data"
        g_mapper_name="afrodite-encrypted-data-mapper"
        g_mapper_file="/dev/mapper/$g_mapper_name"
    else
        echo "Unsupported storage directory '$1'"
        exit 1
    fi
}

# Input: STDIN = storage password, $1 = STORAGE_SIZE_IN_BYTES
function extend_size_and_open_storage_and_quit() {
    set -x

    current_storage_size=$(stat --printf="%s" "$g_encrypted_file")

    if [ "$1" -gt "$current_storage_size" ]; then
        allocate_storage=true
    else
        allocate_storage=false
    fi

    if [ "$allocate_storage" = true ]; then
        fallocate -l "$1" "$g_encrypted_file"
    fi

    cryptsetup --key-file - luksOpen "$g_encrypted_file" "$g_mapper_name"

    if [ "$allocate_storage" = true ]; then
        resize2fs "$g_mapper_file"
    fi

    mount "$g_mapper_file" "$g_storage_dir"
    exit 0
}

function close_storage_and_quit() {
    set -x
    umount "$g_storage_dir"
    cryptsetup luksClose "$g_mapper_name"
    exit 0
}

function is_default_password_and_quit() {
    set -x
    cryptsetup --test-passphrase --key-file - luksOpen "$g_encrypted_file" <<< "$DEFAULT_STORAGE_PASSWORD"
    exit 0
}

### Input: STDIN = new storage password
function change_default_password_and_quit() {
    # The bash option -x is not set to allow shred to run when
    # cryptsetup command fails.

    key_dir="/afrodite-encrypted-filesystem/keyfs"
    key_file="$key_dir/new-key"

    mkdir -p "$key_dir"
    mount -t tmpfs -o size=10M tmpfs "$key_dir"
    cat > "$key_file"

    cryptsetup --key-file - luksChangeKey "$g_encrypted_file" "$key_file" <<< "$DEFAULT_STORAGE_PASSWORD"

    result_of_cryptsetup=$?

    shred -u "$key_file"

    if [ $? -eq 0 ]; then
        echo "Erasing key file succeeded"
    else
        echo "Erase of key file failed"
    fi

    umount "$key_dir"

    if [ $? -eq 0 ]; then
        echo "Unmounting key tmpfs succeeded"
    else
        echo "Unmounting key tmpfs failed"
    fi

    exit $result_of_cryptsetup
}

if [ $# == 0 ]; then
    print_help_and_quit
fi

setup_global_variables "$2"

if [ $# -ge 3 ]; then
    storage_size_in_bytes="$3"
else
    storage_size_in_bytes="0"
fi

case "$1" in
    "$CMD_EXTEND_SIZE_AND_OPEN") extend_size_and_open_storage_and_quit "$storage_size_in_bytes" ;;
    "$CMD_CLOSE") close_storage_and_quit ;;
    "$CMD_IS_DEFAULT_PASSWORD") is_default_password_and_quit ;;
    "$CMD_CHANGE_DEFAULT_PASSWORD") change_default_password_and_quit ;;
    *) echo "Unsupported command '$1'"
       exit 1
    ;;
esac
