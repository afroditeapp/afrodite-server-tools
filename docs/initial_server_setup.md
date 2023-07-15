
1. Use minimal cloud init template.

2. Create new server

3. Login as app_admin_user_with_ssh user

4. Create file
```
  # SSH key for app server tools downloading
  - path: /app-keys/app-server-tools-download.key
    permissions: "0644"
    # user root
    defer: true
    append: false
    content: |
      -----BEGIN OPENSSH PRIVATE KEY-----
      TODO
      -----END OPENSSH PRIVATE KEY-----
```

sudo mkdir /app-keys
sudo vim /app-keys/app-server-tools-download.key
sudo chown root:root /app-keys/app-server-tools-download.key
sudo chmod 644 /app-keys/app-server-tools-download.key

5. Create optional files

```
  # If this file is omitted then SSH will be available to every IP after country filter
  - path: /home/app/ssh_ip.txt
    owner: app:app
    permissions: "0644"
    defer: true
    append: false
    content: |
      192.168.0.0/16
  - path: /home/app/app_manager_ip.txt
    owner: app:app
    permissions: "0644"
    defer: true
    append: false
    content: |
      192.168.0.0/16
```

More optional content:

```
  # For multipass instances
  # - path: /home/app/disable_country_fi_filter
  #   owner: app:app
  #   permissions: "0644"
  #   defer: true

  # Add /app-custom/setup-iptables.sh or /app-custom/post-setup.sh here if
  # wanted
  # - path: /app-custom/setup-iptables.sh
  #   permissions: "0644"
  #   defer: true
  #   append: false
  #   content: |
  #     #!/bin/bash -eu
  #     # Setup iptables
  # - path: /app-custom/post-setup.sh
  #   permissions: "0644"
  #   defer: true
  #   append: false
  #   content: |
  #     #!/bin/bash -eu
  #     echo test

```

6. Run
```
  cd /home/app_admin_user_with_ssh && sudo -u app_admin_user_with_ssh git clone -c "core.sshCommand=ssh -i /app-keys/app-server-tools-download.key" --depth 1 git@github.com:jutuon/app-server-tools.git
  cd /home/app_admin_user_with_ssh/app-server-tools && sudo bash -eux /home/app_admin_user_with_ssh/app-server-tools/setup-environment.sh
  sudo systemctl enable fail2ban
  sudo systemctl start fail2ban
```

Note that github known hosts thing will be asked.


7. Add SSH service config

This makes sure that only app_admin_user_with_ssh user has SSH access.

Add

```
AllowUsers app_admin_user_with_ssh
```

to end of /etc/ssh/sshd_config

and run

```
sudo systemctl restart sshd
```

8. Move to next instructions.

If you are initializing build server then read build_server_setup.md.
