#!/bin/bash

echo ""
echo "----------------"
grep 97816 /etc/security/limits.conf || echo "Adding * hard nofile 97816 and * soft nofile 97816 to /etc/security/limits.conf"

grep 97816 /etc/security/limits.conf || echo -e "* hard nofile 97816\n* soft nofile 97816" >> /etc/security/limits.conf
