
1. Create Ubuntu Server 22.04 VPS instance. Instructions assume
that you are logged in with username ubuntu.

2. Install dependencies:

```bash
sudo apt install git ansible
```

3. Login to server and run inital setup script.

```bash
  cd /home/ubuntu && sudo -u ubuntu git clone --depth 1 https://github.com/afroditeapp/afrodite-server-tools
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

5. Follow setup-environment.sh instructions about iptables and Fail2Ban.
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

6. Setup TLS certificates for afrodite-backend manager mode
  instance. Check instructions in [manager_tls_setup.md](./manager_tls_setup.md).

7. Download
[afrodite-backend binary](https://github.com/afroditeapp/afrodite-backend/releases)
to `/home/afrodite/afrodite-backend`.

8. Configure the manager instance and restart it

```bash
  # Create default config file
  sudo systemctl restart afrodite-manager
  sudo -u afrodite vim /home/afrodite/manager_config.toml
  sudo systemctl restart afrodite-manager
```

API password for manager instances can be generated using:
```bash
openssl rand -base64 32
```

Password for encrypted storage can be generated using:
```bash
openssl rand -base64 512
```

If you want to check log output constantly then use:
```bash
sudo journalctl -u afrodite-manager.service -f
```
