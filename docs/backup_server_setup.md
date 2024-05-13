# Backup server setup

1. Do initial_server_setup.md first.
2. Install GPG key for decrypting binaries from build server.

Run in build server:
```
  sudo -u app gpg --output software-builder.key.gpg --export-secret-key app-manager-software-builder
```

Transfer key to backup server and run:
```
  sudo -u app gpg --import software-builder.key.gpg
```

3. Install app-manager using script.

```
  cd ansible
  sudo ansible-playbook setup-app-manager.yaml --extra-vars "manager_url=https://localhost:5000 api_key=password"
  sudo systemctl start app-manager
```

Note that if you have custom TLS certificate it is not needed as
certificate validation is disabled in `setup-app-manager.yaml`. That is safe
because GPG checks that binary is not tampered.

4. Configure app-manager properly and restart it

```
  sudo vim /home/app/manager-working-dir/manager_config.toml
  sudo systemctl restart app-manager
```
