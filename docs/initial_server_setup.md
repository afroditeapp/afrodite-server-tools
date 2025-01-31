
1. Create Ubuntu Server 22.04 VPS instance. Instructions assume
that you are logged in with username ubuntu.

2. Install dependencies:

```bash
sudo apt install git ansible
```

3. Login to server and run inital setup script.

```bash
  cd /home/ubuntu && sudo -u ubuntu git clone --depth 1 https://github.com/jutuon/afrodite-server-tools
  cd /home/ubuntu/afrodite-server-tools
  # And run script and read instructions
  sudo bash -eu /home/ubuntu/afrodite-server-tools/setup-environment.sh
```

4. Make SSH more secure. (This is not required but it is better to use
more secure settings.)

For example when your username is ubuntu, add the next lines

```
AllowUsers ubuntu
PasswordAuthentication no
```

to end of /etc/ssh/sshd_config and run

```bash
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
```bash
sudo netfilter-persistent save
```

Appending the saved rules to current rules can be done using
```bash
sudo netfilter-persistent reload
# or
sudo netfilter-persistent start
```

Modified IPv4 rules file can be loaded using
```bash
sudo bash -c "iptables-restore < /etc/iptables/rules.v4"
```

9. Move to next instructions.

If you are initializing build server then read build_server_setup.md.
