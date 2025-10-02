#!/bin/bash

#Author: Sameer Jain
#Dated: 30-09-2025
#Version: v2
#Purpose: Launch an EC2 instance, perform operations, and stop it automatically.

INSTANCE_ID="i-XXXXXXXXXXXXX"        
SSH_KEY_PATH="$HOME/path/to/key.pem" 
SSH_USER="ubuntu"                    

# Start the EC2 instance
aws ec2 start-instances --instance-ids "$INSTANCE_ID" >/dev/null

# Keep checking for the status until it is "running"
status=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[*].Instances[*].State.Name" --output text)
counter=1
while [[ "$status" != "running" && "$counter" -lt 30 ]]; do
    status=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[*].Instances[*].State.Name" --output text)
    counter=$((counter+1))
    sleep 1
done

if [[ "$status" != "running" && "$counter" -eq 30 ]]; then
    echo "Try again!"
    exit
fi

# Retrieve the public IP of the instance
ec2address=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[*].Instances[*].PublicIpAddress" --output text)

echo "Waiting for SSH to become available on $ec2address ..."
for i in {1..20}; do
# -z allows us to check only if a connection can be made on the port or not, we can prevent sending any data over nc (netcat) using -z and just test for connectivity.
# checking for 20 seconds if the port is open, if the port is not open then we can try again, or there might be something wrong with the instance.
    nc -z "$ec2address" 22 >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "SSH is ready."
        break
    fi
    sleep 2
done

# If still not reachable
nc -z "$ec2address" 22 >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "SSH not available. Exiting."
    exit
fi


if [ -z "$ec2address" ]; then
    echo "Try again!"
    exit
fi

# SSH into the instance
ssh -i "$SSH_KEY_PATH" "$SSH_USER@$ec2address"

# Stop the EC2 instance
aws ec2 stop-instances --instance-ids "$INSTANCE_ID" >/dev/null
