#!/bin/bash -eu

# Print logs requiring root access

UNATTENDED_UPGRADES_LOG=/var/log/unattended-upgrades/unattended-upgrades.log

if [ -f "$UNATTENDED_UPGRADES_LOG" ]; then
    echo "Latest lines from $UNATTENDED_UPGRADES_LOG"
    tail "$UNATTENDED_UPGRADES_LOG"
else
    echo "No unattended upgrades log found"
fi
