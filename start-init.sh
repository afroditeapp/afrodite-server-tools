#!/bin/bash -eu

# Run this from cloud init as app_admin_user_with_ssh user

cd /home/app_admin_user_with_ssh && sudo -u app_admin_user_with_ssh git clone -c "core.sshCommand=ssh -i /app-keys/app-server-tools-download.key" --depth 1 git@github.com:jutuon/app-server-tools.git
cd /home/app_admin_user_with_ssh/app-server-tools && bash -eux /home/app_admin_user_with_ssh/app-server-tools/setup-environment.sh
systemctl enable fail2ban
systemctl start fail2ban
