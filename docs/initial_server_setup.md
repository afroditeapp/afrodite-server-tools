
1. Create Ubuntu server 22.04 VPS instance. If you want create another user
named app_admin_user_with_ssh for SSH access check minimal cloud init template.

Rest of the instructions assume that you have created user named
app_admin_user_with_ssh. Replace the username with your own if you have another
username.

If you don't use cloud init template then you also need install dependencies:

```
sudo apt install git ansible
```

6. Login to server and run inital setup script.

When username is app_admin_user_with_ssh:
```
  cd /home/app_admin_user_with_ssh && sudo -u app_admin_user_with_ssh git clone --depth 1 https://github.com/jutuon/app-server-tools
  cd /home/app_admin_user_with_ssh/app-server-tools
  # And run script and read instructions
  sudo bash -eu /home/app_admin_user_with_ssh/app-server-tools/setup-environment.sh
```

When username is ubuntu:
```
  cd /home/ubuntu && sudo -u ubuntu git clone --depth 1 https://github.com/jutuon/app-server-tools
  cd /home/ubuntu/app-server-tools
  # And run script and read instructions
  sudo bash -eu /home/ubuntu/app-server-tools/setup-environment.sh
```

Note that github known hosts thing will be asked.

7. Make SSH more secure. (Is this required? Should not, but it is better to use
more secure settings.)

For example if your username is app_admin_user_with_ssh:

Add

```
AllowUsers app_admin_user_with_ssh
PasswordAuthentication no
```

to end of /etc/ssh/sshd_config

and run

```
sudo systemctl restart sshd
```

8. Check that saved iptables rules are correct.

VPS providers might have their own firewall rules before the ones the script
added. The rules are saved in `/app-iptables` directory.

9. Move to next instructions.

If you are initializing build server then read build_server_setup.md.
