# Build server setup

1. Do initial_server_setup.md first.
2. Add SSH key for downloading backend code.

Create file with content like this:
```
  -----BEGIN OPENSSH PRIVATE KEY-----
  TODO
  -----END OPENSSH PRIVATE KEY-----
```

sudo -u afrodite mkdir /afrodite-secure-storage/afrodite/.ssh
sudo -u afrodite vim /afrodite-secure-storage/afrodite/.ssh/afrodite-backend-download.key

3. Install dependencies and bootstrap build server using script.

```
  sudo apt install build-essential libssl-dev pkg-config
  sudo -u afrodite bash -eu /afrodite-server-tools/setup-tools/bootstrap-build-server.sh
  sudo systemctl start afrodite-manager
```

4. Generate TLS certificate for afrodite-manager. It is best to do this on your local
machine as you will need to copy these to all VMs which are running afrodite-manager.

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

Second, sign a second level certificate for afrodite-manager.
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
sudo -u afrodite mkdir /home/afrodite/manager-working-dir/tls
sudo cp root.crt server.crt server.key /home/afrodite/manager-working-dir/tls
sudo chown -R afrodite:afrodite /home/afrodite/manager-working-dir/tls
```

5. Configure afrodite-manager properly and restart it

```
  sudo -u afrodite vim /home/afrodite/manager-working-dir/manager_config.toml
  sudo systemctl restart afrodite-manager
```

Password for afrodite-manager can be generated using:
```
openssl rand -base64 32
```

Password for encrypted storage can be generated using:
```
openssl rand -base64 512
```

If you want to check log output constantly then use:
```
sudo journalctl -u afrodite-manager.service -f
```

GPG key which afrodite-manager generates can be exported using:
```
sudo -u afrodite bash -l
gpg --export-secret-keys afrodite-manager-software-builder > build-server-binary-encryption-private-key.gpg
```

The secret key is needed for binary decryption on servers which download
binaries from afrodite-manager. Key export seems to have a+r permissions, remove
file when it is not needed.
