# Manager TLS setup

Generate TLS certificate for afrodite-backend manager mode instances.
It is best to do this on your local machine as you will need to copy these to
all VMs which are running an manager instance.

## rustls-cert-gen

1. Install [rustls-cert-gen](https://crates.io/crates/rustls-cert-gen).
2. From the following command, replace
   `OUTPUT_DIR`, `ADDRESS`, `COUNTRY` and `ORGANIZATION`
   with wanted values and run the edited command.

```bash
rustls-cert-gen -o OUTPUT_DIR --ecdsa-p384 --san=ADDRESS --country-name=COUNTRY --organization-name=ORGANIZATION
```

## OpenSSL

The following instructions do not work with Rustls which is the only
supported TLS library for manager TLS connections.

TODO: The following instructions should be updated so that generated
second level sertificate has SAN (Subject Alternative Name) certificate field.
Rustls seems to require the field. CN field can be empty.

First, generate a self signed root certificate:

```bash
mkdir root
# Generate private key:
openssl genrsa -out root/root.key 4096
# Create certificate signing request (CSR):
openssl req -extensions v3_req -new -sha256 -key root/root.key -out root/root.csr
# Sign root certificate:
openssl x509 -req -sha256 -days 36500 -in root/root.csr -signkey root/root.key -out root/root.crt
```

(100 years = 36500 days)

Second, sign a second level certificate for an manager instance.
Use domain as Common Name. IP address does not work with Dart and Rustls.

```bash
mkdir server
openssl genrsa -out server/server.key 4096
openssl req -extensions v3_req -new -sha256 -key server/server.key -out server/server.csr
openssl x509 -req -in server/server.csr -CA root/root.crt -CAkey root/root.key -CAcreateserial -out server/server.crt -days 36500 -sha256
```

The new certificate can be viewed using command:
```bash
openssl x509 -in server/server.crt -text -noout
```

Use scp to copy root/root.crt, server/server.crt and server/server.key to VM.

Modify this command to match with your case:
```bash
scp root/root.crt server/server.crt server/server.key username@remote_host:~/
```

On VM:

```bash
sudo -u afrodite mkdir /home/afrodite/manager-tls
sudo cp root.crt server.crt server.key /home/afrodite/manager-tls
sudo chown -R afrodite:afrodite /home/afrodite/manager-tls
```
