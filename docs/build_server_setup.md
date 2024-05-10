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

4. Generate TLS certificate for app-manager. It is best to do this on your local
machine as you will need to copy these to all VMs which are running app-manager.

First, generate a self signed root certificate:

```
mkdir root
# Generate private key:
openssl genrsa -out root/root.key 4096
# Create certificate signing request (CSR):
openssl req -new -sha256 -key root/root.key -out root/root.csr
# Sign root certificate:
openssl x509 -req -sha256 -days 36500 -in root/root.csr -signkey root/root.key -out root/root.crt
```

(100 years = 36500 days)

Second, sign a second level certificate for app-manager.
Use domain as Common Name. IP address does not work with Dart and Rustls.

```
mkdir server
openssl genrsa -out server/server.key 4096
openssl req -new -sha256 -key server/server.key -out server/server.csr
openssl x509 -req -in server/server.csr -CA root/root.crt -CAkey root/root.key -CAcreateserial -out server/server.crt -days 36500 -sha256
```

The new certificate can be viewed using command:
```
openssl x509 -in server/server.crt -text -noout
```

Use scp to copy root/root.crt, server/server.crt and server/server.key to VM.

Modify this command to match with your case:
```
scp root/root.crt server/server.crt server/server.key username@remote_host:~/
```

On VM:

```
sudo -u app mkdir /home/app/manager-working-dir/tls
sudo cp root.crt server.crt server.key /home/app/manager-working-dir/tls
sudo chown -R app:app /home/app/manager-working-dir/tls
```

5. Configure app-manager properly and restart it

```
  sudo -u app vim /home/app/manager-working-dir/manager_config.toml
  sudo systemctl restart app-manager
```

Password for app-manager can be generated using:
```
openssl rand -base64 32
```

Password for encrypted storage can be generated using:
```
openssl rand -base64 512
```

If you want to check log output constantly then use:
```
sudo journalctl -u app-manager.service -f
```
