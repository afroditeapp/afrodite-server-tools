#!/bin/bash -eu

# Update country IP address set

IP_LIST_NAME=fi_ip.txt
IP_SET=country_fi
IP_SET_NEW=country_fi_new

sudo -u afrodite python3 \
    /afrodite-server-tools/setup-tools/download-ip-list.py \
    --file "/home/afrodite/$IP_LIST_NAME" \
    --country fi

if [ $? -ne 0 ]; then
    echo "Downloading new IP list failed"
    exit 1
else
    echo "New IP list downloaded"
fi

ipset -exist destroy "$IP_SET_NEW"

if [ $? -ne 0 ]; then
    echo "Destroying temporary IP set failed"
    exit 1
else
    echo "Destroying temporary IP set was successful"
fi

python3 \
    /afrodite-server-tools/setup-tools/setup-ipset.py \
    --file "/home/afrodite/$IP_LIST_NAME" \
    --name "$IP_SET_NEW"

if [ $? -ne 0 ]; then
    echo "Creating new ipset failed"
    exit 1
else
    echo "Creating temporary IP set was successful"
fi

ipset swap "$IP_SET" "$IP_SET_NEW"

if [ $? -ne 0 ]; then
    echo "Swapping current IP set with new failed"
    exit 1
else
    echo "Swapping current IP set with new completed"
fi

ipset -exist destroy "$IP_SET_NEW"

if [ $? -ne 0 ]; then
    echo "Destroying old IP set failed"
    exit 1
else
    echo "Destroying old IP set completed"
fi
