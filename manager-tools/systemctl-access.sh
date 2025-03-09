#!/bin/bash -eu

DEFAULT_SERVICE="afrodite-backend.service"

CMD_START="start"
CMD_STOP="stop"

if [ $# == 0 ]; then
    echo "Usage: sudo bash -eu systemctl-access.sh COMMAND SERVICE"
    echo "Available commands: $CMD_START, $CMD_STOP"
    echo "Available services: $DEFAULT_SERVICE"
    exit 1
fi

if [ "$2" == "$DEFAULT_SERVICE" ]; then
    selected_service="$DEFAULT_SERVICE"
else
    echo "Unsupported service name '$2'"
    exit 1
fi

if [ "$1" == "$CMD_START" ] || [ "$1" == "$CMD_STOP" ]; then
    systemctl "$1" "$selected_service"
else
    echo "Unsupported action '$1'"
    exit 1
fi
