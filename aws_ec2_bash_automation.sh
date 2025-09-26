#AWS EC2 Automation Script
#!/bin/bash

# Author: Sameer Jain
# Purpose: Launch an EC2 instance, perform operations, and stop it automatically.
# Version: v1

INSTANCE_ID="i-XXXXXXXXXXXXXXX"
SSH_KEY_PATH="path/to/your/key.pem"
INSTANCE_DNS="ec2-XX-XXX-XXX-XXX.compute.amazonaws.com"

output=$(aws ec2 start-instances --instance-ids "$INSTANCE_ID")

prev_state=$(echo "$output" | jq -r '.StartingInstances[0].PreviousState.Name')
curr_state=$(echo "$output" | jq -r '.StartingInstances[0].CurrentState.Name')

if [ "$prev_state" = "running" ]; then
    echo "Instance already running"
else
    count=0
    while [ $count -lt 30 ]; do
        status=$(aws ec2 describe-instance-status --instance-ids "$INSTANCE_ID" \
                 --output json | jq -r 'if .InstanceStatuses | length == 0 then "pending" else .InstanceStatuses[0].InstanceState.Name end')
        [ "$status" = "running" ] && break
        sleep 5
        count=$((count+1))
    done
fi

ssh -i "$SSH_KEY_PATH" ubuntu@"$INSTANCE_DNS"

aws ec2 stop-instances --instance-ids "$INSTANCE_ID"
