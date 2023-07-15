

jail.local - Jail2ban config

```
  - path: /etc/fail2ban/jail.local
    permissions: "0644"
    defer: true
    append: false
    content: |
      [DEFAULT]
      bantime = 1y
      maxretry = 1

      [sshd]
      enabled = true
```
