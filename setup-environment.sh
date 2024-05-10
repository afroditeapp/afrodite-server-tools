#!/bin/bash -eux

# Run this as root

current_dir=$(basename "$(pwd)")

if [ $# == 0 ]; then
    echo "Usage: sudo bash -eu setup-environment.sh encrypted_file_size=5G"
    echo ""
    echo "Fail2ban will not be enabled by default." \
        "It can be enabled by running" \
        "'sudo systemctl enable fail2ban' and" \
        "'sudo systemctl start fail2ban'" \
        "after this script."
    echo ""
    echo "Required config:"
    echo "/app-custom/ssh_ip.txt -" \
        "IP address whitelist for SSH. File should contain" \
        "192.168.0.0/16 like lines"
    echo "/app-custom/app_manager_ip.txt -" \
        "IP address whitelist for app-manager. File should contain" \
        "192.168.0.0/16 like lines"
    echo ""
    echo "Other config:"
    echo "/app-custom/setup_iptables.sh -" \
        "Override default iptables rules"
    echo "/app-custom/post_setup.sh -" \
        "Run custom commands after server init"
    echo "/app-custom/disable_country_fi_filter -" \
        "Disable iptables country FI filter"

    exit 1
fi

if [ ! -f "/app-custom/ssh_ip.txt" ]; then
    echo "Error: /app-custom/ssh_ip.txt does not exist"
    exit 1
fi

if [ ! -f "/app-custom/app_manager_ip.txt" ]; then
    echo "Error: /app-custom/app_manager_ip.txt does not exist"
    exit 1
fi

if [[ "$current_dir" != "app-server-tools" ]]; then
  echo "Error: Current directory is not 'app-server-tools'. Exiting..."
  exit 1
fi

# Install to root
cp -r ../app-server-tools /

# Continue from installation
cd /app-server-tools/ansible

ansible-playbook server-init.yaml --extra-vars "$1"

echo "Setup completed without errors $(date)" > setup_is_complete.txt
