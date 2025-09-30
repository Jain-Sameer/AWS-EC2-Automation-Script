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

if [ -z "$ec2address" ]; then
    echo "Try again!"
    exit
fi

# SSH into the instance
ssh -i "$SSH_KEY_PATH" "$SSH_USER@$ec2address"

# Stop the EC2 instance
aws ec2 stop-instances --instance-ids "$INSTANCE_ID" >/dev/null
