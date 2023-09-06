#!/bin/bash -eux

# Run this as root

current_dir=$(basename "$(pwd)")

if [[ "$current_dir" != "app-server-tools" ]]; then
  echo "Error: Current directory is not 'app-server-tools'. Exiting..."
  exit 1
fi

# Install to root
cp -r ../app-server-tools /

# Continue from installation
cd /app-server-tools/ansible

ansible-playbook server-init.yaml

echo "Setup completed without errors $(date)" > setup_is_complete.txt
