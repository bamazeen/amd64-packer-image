# IBM Confidential
# OCO Source Materials
# CLD-119483-1646939465
# (c) Copyright IBM Corp. 2023
# The source code for this program is not published or otherwise
# divested of its trade secrets, irrespective of what has been
# deposited with the U.S. Copyright Office.

#!/bin/bash

function retry {
  local max=$1; shift
  local delay=$1; shift
  local cmd=($@)
  local n=1
  while true; do
    "${cmd[@]}" && break || {
      if [[ $n -lt $max ]]; then
        echo "Command failed. Attempt $n/$max\n"
        ((n++))
        sleep $delay
      else
        echo "The command has failed after $n attempts."
        exit 1
      fi
    }
  done
}

export ANSIBLE_HOST_KEY_CHECKING=False

apt-get list | grep unattended
retry 10 60 sudo apt remove unattended-upgrades -y
apt-get list | grep unattended
retry 10 60 sudo apt purge unattended-upgrades -y
apt-get list | grep unattended
