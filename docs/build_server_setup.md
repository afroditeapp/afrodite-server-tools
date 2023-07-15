# Build server setup

1. Do initial_server_setup.md first.
2. Add SSH keys for downloading code.

```
 - path: /app-secure-storage/app/.ssh/app-backend-download.key
    owner: app:app
    permissions: "0600"
    defer: true
    append: true
    content: |
      -----BEGIN OPENSSH PRIVATE KEY-----
      TODO
      -----END OPENSSH PRIVATE KEY-----
  - path: /app-secure-storage/app/.ssh/app-manager-download.key
    owner: app:app
    permissions: "0600"
    defer: true
    append: true
    content: |
      -----BEGIN OPENSSH PRIVATE KEY-----
      TODO
      -----END OPENSSH PRIVATE KEY-----
```

sudo -u app mkdir /app-secure-storage/app/.ssh
sudo -u app vim /app-secure-storage/app/.ssh/app-backend-download.key
sudo -u app vim /app-secure-storage/app/.ssh/app-manager-download.key

3. Install dependencies and bootstrap app manager using script.

```
    sudo apt install build-essential libssl-dev pkg-config
    sudo -u app bash -eux /app-server-tools/setup-tools/bootstrap-build-server.sh
    sudo systemctl start app-manager
```

4. Configure app-manager properly and restart it

```
  # Server app config files
  - path: /home/app/manager-working-dir/manager_config.toml
    owner: app:app
    permissions: "0644"
    defer: true
    append: true
    content: |
      # TODO: changes needed

      # Required
      # api_key = "password"

      [socket]
      public_api = "0.0.0.0:5000"

      [environment]
      secure_storage_dir = "/app-secure-storage/app"
      scripts_dir = "/app-server-tools/manager-tools"

      # [encryption_key_provider]
      # manager_base_url = "http://127.0.0.1:5000"
      # key_name = "test-server"

      # [[server_encryption_keys]]
      # name = "test-server"
      # key_path = "data-key.key"

      # [software_update_provider]
      # manager_base_url = "http://127.0.0.1:5000"
      # binary_signing_public_key = "binary-key.pub"
      # manager_install_location = "/home/app/binaries/app-manager"
      # backend_install_location = "/app-secure-storage/app/binaries/app-backend"

      # [software_builder]
      # manager_download_key_path = "app-manager.key"
      # manager_download_git_address = "git repository ssh address"
      # manager_branch = "main"
      # manager_binary = "app-manager"
      # manager_pre_build_script = "/path/to/script/app-manager-pre-build.sh" # Optional
      # backend_download_key_path = "app-backend.key"
      # backend_download_git_address = "git repository ssh address"
      # backend_branch = "main"
      # backend_binary = "app-backend"
      # backend_pre_build_script = "/path/to/script/app-backend-pre-build.sh" # Optional

      # [reboot_if_needed]
      # time = "12:00"

      # [tls]
      # public_api_cert = "server_config/public_api.cert"
      # public_api_key = "server_config/public_api.key"
      # root_certificate = "server_config/public_api.key"
```

```
    sudo systemctl restart app-manager
```

7. After app-manager can get the encryption key for secure data storage,
   replace the current encryption key for it.

   The default encryption key is `password`
