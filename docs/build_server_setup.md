# Build server setup

1. Do initial_server_setup.md first.
2. Add SSH key for downloading backend code.

Create file with content like this:
```
  -----BEGIN OPENSSH PRIVATE KEY-----
  TODO
  -----END OPENSSH PRIVATE KEY-----
```

sudo -u app mkdir /app-secure-storage/app/.ssh
sudo -u app vim /app-secure-storage/app/.ssh/app-backend-download.key

3. Install dependencies and bootstrap build server using script.

```
  sudo apt install build-essential libssl-dev pkg-config
  sudo -u app bash -eu /app-server-tools/setup-tools/bootstrap-build-server.sh
  sudo systemctl start app-manager
```

4. Configure app-manager properly and restart it

```
  sudo vim /home/manager-working-dir/manager_config.toml
  sudo systemctl restart app-manager
```
