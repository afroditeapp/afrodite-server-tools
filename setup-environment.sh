#!/bin/bash -eux

# Run this from cloud init as root

CUSTOM_SETUP_IPTABLES=/app-custom/setup-iptables.sh
CUSTOM_POST_SETUP=/app-custom/post-setup.sh

current_dir=$(basename "$(pwd)")

if [[ "$current_dir" != "app-server-tools" ]]; then
  echo "Error: Current directory is not 'app-server-tools'. Exiting..."
  exit 1
fi

# Install to root
cp -r ../app-server-tools /

# Continue from installation
cd /app-server-tools

# Setup new services
cp services/* /etc/systemd/system
systemctl daemon-reload
systemctl enable app-manager
systemctl enable app-load-iptables
systemctl enable app-disable-swap
systemctl start app-disable-swap

chmod u+x /app-server-tools/manager-tools/is-default-encryption-password.sh
chmod u+x /app-server-tools/manager-tools/change-encryption-password.sh
chmod u+x /app-server-tools/manager-tools/open-encryption.sh
chmod u+x /app-server-tools/manager-tools/close-encryption.sh
chmod u+x /app-server-tools/manager-tools/start-backend.sh
chmod u+x /app-server-tools/manager-tools/stop-backend.sh
chmod u+x /app-server-tools/tools/load-iptables.sh

# Create location for ipset and iptables
mkdir /app-iptables

# Setup ipsets
cd /home/app
sudo -u app python3 /app-server-tools/setup-tools/download-ip-list.py --file fi_ip.txt --country fi
cd /app-server-tools
# country_fi ipset
ipset create country_fi hash:net
python3 setup-tools/setup-ipset.py --file /home/app/fi_ip.txt --name country_fi
# ssh_access ipset
ipset create ssh_access hash:net
if [ -f "/home/app/ssh_ip.txt" ]; then
    python3 setup-tools/setup-ipset.py --file /home/app/ssh_ip.txt --name ssh_access
fi
# app_manager_access ipset
ipset create app_manager_access hash:net
if [ -f "/home/app/app_manager_ip.txt" ]; then
    python3 setup-tools/setup-ipset.py --file /home/app/app_manager_ip.txt --name app_manager_access
fi
ipset save > /app-iptables/ipset.save

if [ -f "$CUSTOM_SETUP_IPTABLES" ]; then
    bash -eu "$CUSTOM_SETUP_IPTABLES"
else
    bash -eu setup-tools/setup-iptables.sh
fi

iptables-save > /app-iptables/ip4tables.save
ip6tables-save > /app-iptables/ip6tables.save

bash -eu setup-tools/setup-encrypted-fs.sh

cp files/jail.local /etc/fail2ban/jail.local
chown root:root /etc/fail2ban/jail.local
chmod 644 /etc/fail2ban/jail.local

if [ -f "$CUSTOM_POST_SETUP" ]; then
    bash -eu "$CUSTOM_POST_SETUP"
fi

echo "Setup completed without errors $(date)" > setup_is_complete.txt
