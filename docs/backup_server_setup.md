# Backup server setup

1. Do initial_server_setup.md first.
2. Install GPG key for decrypting binaries from build server.

Run in build server:
```
  sudo -u afrodite gpg --output software-builder.key.gpg --export-secret-key afrodite-manager-software-builder
```

Transfer key to backup server and run:
```
  sudo -u afrodite gpg --import software-builder.key.gpg
```

3. Install afrodite-manager using script.

```
  cd ansible
  sudo ansible-playbook setup-afrodite-manager.yaml --extra-vars "manager_url=https://localhost:5000 api_key=password"
  sudo systemctl start afrodite-manager
```

Note that if you have custom TLS certificate it is not needed as
certificate validation is disabled in `setup-afrodite-manager.yaml`. That is safe
because GPG checks that binary is not tampered.

4. Configure afrodite-manager properly and restart it

```
  sudo vim /home/afrodite/manager-working-dir/manager_config.toml
  sudo systemctl restart afrodite-manager
```
