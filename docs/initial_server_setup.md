
1. Create Ubuntu server 22.04 VPS instance. If you want create another user
named afrodite_admin_user_with_ssh for SSH access check minimal cloud init template.

Rest of the instructions assume that you have created user named
afrodite_admin_user_with_ssh. Replace the username with your own if you have another
username.

If you don't use cloud init template then you also need install dependencies:

```
sudo apt install git ansible
```

6. Login to server and run inital setup script.

When username is afrodite_admin_user_with_ssh:
```
  cd /home/afrodite_admin_user_with_ssh && sudo -u afrodite_admin_user_with_ssh git clone --depth 1 https://github.com/jutuon/afrodite-server-tools
  cd /home/afrodite_admin_user_with_ssh/afrodite-server-tools
  # And run script and read instructions
  sudo bash -eu /home/afrodite_admin_user_with_ssh/afrodite-server-tools/setup-environment.sh
```

When username is ubuntu:
```
  cd /home/ubuntu && sudo -u ubuntu git clone --depth 1 https://github.com/jutuon/afrodite-server-tools
  cd /home/ubuntu/afrodite-server-tools
  # And run script and read instructions
  sudo bash -eu /home/ubuntu/afrodite-server-tools/setup-environment.sh
```

Note that github known hosts thing will be asked.

7. Make SSH more secure. (Is this required? Should not, but it is better to use
more secure settings.)

For example if your username is afrodite_admin_user_with_ssh:

Add

```
AllowUsers afrodite_admin_user_with_ssh
PasswordAuthentication no
```

to end of /etc/ssh/sshd_config

and run

```
sudo systemctl restart sshd
```

8. Follow setup-environment.sh instructions about iptables and Fail2Ban.
Also check that saved iptables rules are correct.

VPS providers might have their own firewall rules before the ones the script
setup_iptables.sh added.

The iptables rules are saved to /etc/iptables/rules.v4 and
/etc/iptables/rules.v6. The ipset config is saved to saved to
/etc/iptables/ipsets.

Saving the rules can be done using
```
sudo netfilter-persistent save
```

Appending the saved rules to current rules can be done using
```
sudo netfilter-persistent reload
# or
sudo netfilter-persistent start
```

Modified IPv4 rules file can be loaded using
```
sudo bash -c "iptables-restore < /etc/iptables/rules.v4"
```

9. Move to next instructions.

If you are initializing build server then read build_server_setup.md.
