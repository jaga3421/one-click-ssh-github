#!/bin/bash

# Prompt the user for their email
read -p "Enter your GitHub email address: " GITHUB_EMAIL

# Define key name and path
KEY_NAME="id_rsa_github"
SSH_KEY_PATH="$HOME/.ssh/$KEY_NAME"

# Check if ssh-keygen is installed
if ! command -v ssh-keygen &> /dev/null; then
    echo "ssh-keygen could not be found. Please install it and try again."
    exit 1
fi

# Check if ssh-agent is installed
if ! command -v ssh-agent &> /dev/null; then
    echo "ssh-agent could not be found. Please install it and try again."
    exit 1
fi

# Check if pbcopy is available (for macOS) or xclip (for Linux)
if command -v pbcopy &> /dev/null; then
    COPY_CMD="pbcopy"
elif command -v xclip &> /dev/null; then
    COPY_CMD="xclip -selection clipboard"
else
    echo "No clipboard utility found. Please copy the key manually."
    COPY_CMD=""
fi

# Generate a new SSH key pair
echo "Generating new SSH key..."
ssh-keygen -t rsa -b 4096 -C "$GITHUB_EMAIL" -f "$SSH_KEY_PATH" -N ""

# Start the SSH agent
echo "Starting ssh-agent..."
eval "$(ssh-agent -s)"

# Add the SSH key to the agent
echo "Adding SSH key to the agent..."
ssh-add "$SSH_KEY_PATH"

# Display the public key and copy it to clipboard
if [ -n "$COPY_CMD" ]; then
    echo "Copying the public key to the clipboard..."
    cat "$SSH_KEY_PATH.pub" | $COPY_CMD
    echo "The public key has been copied to your clipboard."
else
    echo "Clipboard utility not found. Please copy the key manually."
    echo "Your public key is:"
    cat "$SSH_KEY_PATH.pub"
fi

# Provide link to GitHub SSH key settings page
echo "Please add the public key to your GitHub account using the following link:"
echo "https://github.com/settings/keys"

# Echo the command to test SSH connection
echo "To test your SSH connection to GitHub, use the following command:"
echo "ssh -T git@github.com"

echo "Done!"
