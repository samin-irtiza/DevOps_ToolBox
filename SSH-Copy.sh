#!/bin/bash

# Check if any arguments are provided
if [ $# -eq 0 ]; then
  echo "Please provide IP addresses as arguments or a text file containing the IP addresses."
  echo "Usage: $0 [options] [IP_address1] [IP_address2] ..."
  echo "Options:"
  echo "  -h, --help    Display this help message"
  echo "  -f, --filename Read IP addresses from a file"
  exit 1
fi

# Check if --help or -h is provided
while getopts ":hf:" opt; do
  case $opt in
    h)
      echo "Usage: $0 [options] [IP_address1] [IP_address2] ..."
      echo "Options:"
      echo "  -h, --help    Display this help message"
      echo "  -f, --filename Read IP addresses from a file"
      exit 0
      ;;
    f)
      filename="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      echo "Usage: $0 [options] [IP_address1] [IP_address2] ..."
      echo "Options:"
      echo "  -h, --help    Display this help message"
      echo "  -f, --filename Read IP addresses from a file"
      exit 1
      ;;
  esac
done

# Check if the .ssh directory exists in the user's home directory
if [ -d "$HOME/.ssh" ]; then
  # Find all public key files in the .ssh directory
  public_key_files=($(find "$HOME/.ssh" -type f -name "*.pub"))

  if [ ${#public_key_files[@]} -gt 0 ]; then
    # Prompt the user to choose a public key file
    echo "Select the public key to use:"
    select public_key in "${public_key_files[@]}"; do
      if [ -n "$public_key" ]; then
        echo "Selected public key: $public_key"
        break
      else
        echo "Invalid selection. Please choose a valid public key."
      fi
    done
  else
    echo "No SSH public keys found, generating a new key"
    ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
    public_key="$HOME/.ssh/id_rsa.pub"
    echo "New SSH key generated"
  fi
else
    echo "No SSH public keys found, generating a new key"
    ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
    public_key="$HOME/.ssh/id_rsa.pub"
    echo "New SSH key generated"
fi

# Remove the options from the arguments
shift $((OPTIND-1))

# Read IP addresses from a file or from the arguments
if [ -n "$filename" ]; then
  while read -r ip; do
    if [ -n "$ip" ]; then
      IPS+=("$ip")
    fi
  done < "$filename"
else
  for ip in "$@"; do
    IPS+=("$ip")
  done
fi

for ip in "${IPS[@]}"; do
  # Copy the public key to the remote machine
  echo "Copying SSH public key to $ip"
  ssh-copy-id -i "$public_key" "$ip"
done
