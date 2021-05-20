#!/bin/bash

TS_TIMEOUT="timestamp_timeout"
ENVRT="env_reset"
SUDOERS_FILE="/etc/sudoers"
NEW_TIMEOUT="90"
TIMEOUT_REPLACE_STRING="s/$ENVRT/$ENVRT,$TS_TIMEOUT=$NEW_TIMEOUT/"

if grep -q "$TS_TIMEOUT" "$SUDOERS_FILE"; then
  : # timestamp_timeout already written
else
  echo "sed -i $TIMEOUT_REPLACE_STRING $SUDOERS_FILE"
  sed -i "$TIMEOUT_REPLACE_STRING" "$SUDOERS_FILE"
fi
