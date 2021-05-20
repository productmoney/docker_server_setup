#!/bin/bash

echo ""
echo "----------------"

LIMITS_FILE="/etc/security/limits.conf"
FILE_LIMIT="97816"

if grep -q "$FILE_LIMIT" "$LIMITS_FILE"; then
  : # File limits already written
else
  echo "Appended to $LIMITS_FILE:"
  printf "* hard nofile %s\n* soft nofile %s\n" "$FILE_LIMIT" "$FILE_LIMIT" | sudo tee -a "$LIMITS_FILE"
fi
