#!/bin/bash -eu

# -------------- Setup IPv4 firewall ------------------

# Allow localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Allow SSH access from specific IPs
iptables -A INPUT -p tcp --dport 22 -m set --match-set ssh_access src -j ACCEPT

# Allow specific IPs to access app-manager
iptables -A INPUT -p tcp --dport 5000 -m set --match-set app_manager_access src -j ACCEPT

if [ ! -f "/app-custom/disable_country_fi_filter" ]; then
    # Drop all new connections/packets outside Finland.
    iptables -A INPUT -m set ! --match-set country_fi src -j DROP
fi

# Allow SSH access if specific access is not configured
if [ ! -f "/app-custom/ssh_ip.txt" ]; then
    iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
fi

# Allow app-backend access
iptables -A INPUT -p tcp --dport 3000 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

# Allow all outgoing packets
iptables -A OUTPUT -j ACCEPT

# Drop rest
iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP

# -------------- Setup IPv6 firewall ------------------

# Allow localhost
ip6tables -A INPUT -i lo -j ACCEPT
ip6tables -A OUTPUT -o lo -j ACCEPT

# Allow established connections
ip6tables -A INPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Allow all outgoing packets
ip6tables -A OUTPUT -j ACCEPT

# Drop rest
ip6tables -A INPUT -j DROP
ip6tables -A OUTPUT -j DROP
