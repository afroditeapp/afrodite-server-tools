
1. Use minimal cloud init template.

2. Create new server

3. Login as app_admin_user_with_ssh user

6. Run
```
  cd /home/app_admin_user_with_ssh && sudo -u app_admin_user_with_ssh git clone --depth 1 git@github.com:jutuon/app-server-tools.git
  cd /home/app_admin_user_with_ssh/app-server-tools
  # And run script and read instructions
  sudo bash -eu /home/app_admin_user_with_ssh/app-server-tools/setup-environment.sh
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
