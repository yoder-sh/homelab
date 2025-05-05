#!/bin/bash

# Script to copy YAML files to a remote server and populate variables

SOURCE_DIR="../terraform/userdata"
REMOTE_SERVER="root@192.168.120.10"
REMOTE_DIR="/var/lib/vz/snippets"

# Define your variables here
# ===========================
export ANSIBLE_SSH_PUBLIC_KEY=$(aws ssm get-parameter --name "/homelab/ssh-keys/ansible-public-key" --with-decryption --query "Parameter.Value" --output text)
export MBP_SSH_PUBLIC_KEY=$(aws ssm get-parameter --name "/homelab/ssh-keys/mbp-public-key" --with-decryption --query "Parameter.Value" --output text)

# Directory checks
if ! ssh "$REMOTE_SERVER" "[ -d \"$REMOTE_DIR\" ]"; then
  echo "Error: Remote directory $REMOTE_DIR not found on $REMOTE_SERVER."
  exit 1
fi

if [ ! -d "$SOURCE_DIR" ]; then
  echo "Error: Source directory $SOURCE_DIR not found."
  exit 1
fi

# Create a temporary directory for processed files
TMP_DIR=$(mktemp -d)
echo "Created temporary directory: $TMP_DIR"

# Process each YAML file in the source directory
echo "Processing YAML files from $SOURCE_DIR"
for yaml_file in "$SOURCE_DIR"/*.y*ml; do
  if [ -f "$yaml_file" ]; then
    filename=$(basename "$yaml_file")
    echo "Processing $filename"
    
    # Create a processed copy in the temp directory
    cp "$yaml_file" "$TMP_DIR/$filename"
    
    # The sed commands replace ${VARIABLE_NAME} with the actual value
    sed -i '' "s|\${ANSIBLE_SSH_PUBLIC_KEY}|$ANSIBLE_SSH_PUBLIC_KEY|g" "$TMP_DIR/$filename"
    sed -i '' "s|\${MBP_SSH_PUBLIC_KEY}|$MBP_SSH_PUBLIC_KEY|g" "$TMP_DIR/$filename"
    # Add more sed replacements for additional variables as needed
  fi
done

# Copy processed files to remote server
echo "Copying processed YAML files to $REMOTE_SERVER:$REMOTE_DIR"
scp "$TMP_DIR"/*.y*ml "$REMOTE_SERVER:$REMOTE_DIR/"

# Check if the copy was successful
if [ $? -eq 0 ]; then
  echo "Copy Successful!"
else
  echo "Error: Failed to copy files to remote server."
  exit 1
fi

# Clean up temporary directory
echo "Cleaning up temporary files"
rm -rf "$TMP_DIR"

echo "Done!"