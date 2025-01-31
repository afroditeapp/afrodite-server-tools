#!/bin/bash -eux

# Run this as root

current_dir=$(basename "$(pwd)")

if [ $# == 0 ]; then
    echo "Usage: sudo bash -eu setup-environment.sh encrypted_file_size=5G"
    echo ""
    echo "After script completes, setup iptables rules with" \
        "'sudo bash -eu setup-tools/setup_iptables.sh'." \
        "The new iptables and ipset rules are not yet saved." \
        "Install tools to save the rules and load those automatically on boot." \
        "Run 'sudo apt install iptables-persistent ipset-persistent'." \
        "Package install asks should the rules be saved." \
        "Now Fail2Ban can be started if wanted." \
        "It should not be started earlier as it can modify iptables rules."
    echo ""
    echo "Fail2Ban will not be enabled by default." \
        "It can be enabled by running" \
        "'sudo systemctl enable fail2ban' and" \
        "'sudo systemctl start fail2ban'" \
        "after this script."
    echo ""
    echo "Required config:"
    echo "/afrodite-custom/afrodite_manager_ip.txt -" \
        "IP address whitelist for afrodite-manager. File should contain" \
        "192.168.0.0/16 like lines"
    echo ""
    echo "Other config:"
    echo "/afrodite-custom/ssh_ip.txt -" \
        "IP address whitelist for SSH. File should contain" \
        "192.168.0.0/16 like lines"
    echo "/afrodite-custom/disable_country_fi_filter -" \
        "Disable iptables country FI filter"
    echo "/afrodite-custom/disable_non_whitelisted_ssh -" \
        "Disable non-whitelisted SSH access"
    echo "/afrodite-custom/enable_backend_ports -" \
        "Allow port 443 for all IPs and port 3000 after IP country filter"

    exit 1
fi

if [ ! -f "/afrodite-custom/afrodite_manager_ip.txt" ]; then
    echo "Error: /afrodite-custom/afrodite_manager_ip.txt does not exist"
    exit 1
fi

if [[ "$current_dir" != "afrodite-server-tools" ]]; then
  echo "Error: Current directory is not 'afrodite-server-tools'. Exiting..."
  exit 1
fi

# Install to root
cp -r ../afrodite-server-tools /

# Continue from installation
cd /afrodite-server-tools/ansible

ansible-playbook server-init.yaml --extra-vars "$1"

echo "Setup completed without errors $(date)" > setup_is_complete.txt
