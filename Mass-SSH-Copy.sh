#!/bin/bash


echo /****************************/
echo /* Welcome to MASS SSH COPY */
echo /* Written by: samin_irtiza */
echo /****************************/

echo -e "\n"
echo  __  __    _    ____ ____    ____ ____  _   _    ____ ___  ______   __
echo |  \/  |  / \  / ___/ ___|  / ___/ ___|| | | |  / ___/ _ \|  _ \ \ / /
echo | |\/| | / _ \ \___ \___ \  \___ \___ \| |_| | | |  | | | | |_) \ V /
echo | |  | |/ ___ \ ___) |__) |  ___) |__) |  _  | | |__| |_| |  __/ | |
echo |_|  |_/_/   \_\____/____/  |____/____/|_| |_|  \____\___/|_|    |_|


# Check if any arguments are provided
if [ $# -eq 0 ]; then
  echo "Please provide IP addresses as arguments or a text file containing the IP addresses."
  echo "Usage: $0 [options] [IP_address1] [IP_address2] ... | [user@IP_address1] ..."
  echo "Options:"
  echo "  -h, --help    Display this help message"
  echo "  -f, --file    Read IP addresses from a file seperated by linebreak.\n Supports user@remote_ip format"
  echo "  -u, --user    Specify the username for the SSH connection.\nUses the current username by default without the flag"
  exit 1
fi

# Initialize user variable with the current username as the default value
user=$(whoami)
u_flag=0


# Transform long options to short ones
for arg in "$@"; do
  shift
  case "$arg" in
    '--help')    set -- "$@" '-h' ;;
    '--file')    set -- "$@" '-f' ;;
    '--user')    set -- "$@" '-u' ;;
    *)           set -- "$@" "$arg" ;;
  esac
done


# Check if --help, -h, --user, or -u is provided
while getopts ":hf:u:" opt; do
  case $opt in
    h)
      echo "Usage: $0 [options] [IP_address1] [IP_address2] ... | [user@IP_address1] ..."
      echo "Options:"
      echo "  -h, --help    Display this help message"
      echo "  -f, --file    Read IP addresses from a file seperated by linebreak.\n Supports user@remote_ip format"
      echo "  -u, --user    Specify the username for the SSH connection.\nUses the current username by default without the flag"
      exit 0
      ;;
    f)
      filename="$OPTARG"
      ;;
    u)
      user="$OPTARG"
      u_flag=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      echo "Usage: $0 [options] [IP_address1] [IP_address2] ... | [user@IP_address1] ..."
      echo "Options:"
      echo "  -h, --help    Display this help message"
      echo "  -f, --file    Read IP addresses from a file seperated by linebreak.\n Supports user@remote_ip format"
      echo "  -u, --user    Specify the username for the SSH connection.\nUses the current username by default without the flag"
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
  while read -r entry; do
    if [[ $entry =~ ^(.+)@(.+)$ ]]; then
      user="${BASH_REMATCH[1]}"
      ip="${BASH_REMATCH[2]}"
      IPS+=("$user@$ip")
    elif [[ $entry =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      ip="$entry"
      if [ $u_flag -eq 0 ]; then
        IPS+=("$ip")
      else
        IPS+=("$user@$ip")
      fi
    fi
  done < "$filename"
else
  for entry in "${@:OPTIND}"; do
    if [[ $entry =~ ^(.+)@(.+)$ ]]; then
      user="${BASH_REMATCH[1]}"
      ip="${BASH_REMATCH[2]}"
      IPS+=("$user@$ip")
    elif [[ $entry =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      ip="$entry"
      if [ $u_flag -eq 0 ]; then
        IPS+=("$ip")
      else
        IPS+=("$user@$ip")
      fi
    fi
  done
fi

for entry in "${IPS[@]}"; do
  # Copy the public key to the remote machine
  echo "Copying SSH public key to $entry"
  ssh-copy-id -i "$public_key" "$entry"
done
