#!/bin/bash -eu

ipset -exist restore < /app-iptables/ipset.save
ip6tables-restore /app-iptables/ip6tables.save
iptables-restore /app-iptables/ip4tables.save
