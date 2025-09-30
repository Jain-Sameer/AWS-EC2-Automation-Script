# AWS EC2 Automation Script

Automates the lifecycle of an AWS EC2 instance: start → run → stop. Eliminates the need to manually keep your instance running, saving time and cost.

## Features

![Diagram for the flow of the script](https://github.com/Jain-Sameer/AWS-EC2-Automation-Script/blob/main/ec2_aws_script.drawio.png?raw=true)


* Starts an EC2 instance and waits until it’s running.
* Connects to the instance via SSH.
* Stops the EC2 instance after exiting the SSH session.
* Handles asynchronous instance startup using `describe-instance-status` and `jq`.

## Prerequisites

* AWS CLI installed and configured with appropriate credentials.
* `jq` installed for JSON parsing.
* An EC2 key pair (`.pem` file) for SSH access.

## Usage

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/aws-ec2-automation.git
   cd aws-ec2-automation
   ```
2. Update the script with your:

   * `INSTANCE_ID`
   * `SSH_KEY_PATH`
   * `INSTANCE_DNS`
3. Make the script executable:

   ```bash
   chmod +x ec2-automation.sh
   ```
4. Run the script:

   ```bash
   ./ec2-automation.sh
   ```

## Notes

* The script waits up to 2.5 minutes for the instance to reach the `running` state (30 × 5 seconds). Adjust if needed.
* No sensitive credentials should be hard-coded; always use placeholders or environment variables.

## License

MIT
