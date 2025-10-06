import boto3 as b3
import sys
import time
import socket
import subprocess

# NOTE : Some Prerequisites are :
#       1. AWS CLI Installed
#       2. Congifure AWS - 'aws configure'
#       3. Have an access key created in the AWS Dashboard



# creating an ec2 object to work with
ec2 = b3.client("ec2")

#  Listing down all the ec2 instances for the user with the configured access key

instances = ec2.describe_instances()
instanceIds=[]
for i, reservation in enumerate(instances['Reservations']):
    instanceIds.append([reservation['Instances'][0]['InstanceId'], reservation['Instances'][0]['State']['Name']])
for ind,instance in enumerate(instanceIds) :
    print(ind+1, "->", instance[0], "State :",instance[1])
id = int(input("Which instance do you want to run ? Enter the serial no. "))
instanceId = instanceIds[id-1][0]
print(instanceId)


# starting the instance
ec2.start_instances(InstanceIds=[instanceId])

instancedetails = ec2.describe_instance_status(InstanceIds=[instanceId])['InstanceStatuses']
counter = 0 

print("Waiting for the instance to start!")
while len(instancedetails) == 0 and counter < 30:
    instancedetails = ec2.describe_instance_status(InstanceIds=[instanceId])['InstanceStatuses']
    counter = counter + 1
    time.sleep(1)

# checking if even after 30 seconds is the instance running or not
if(len(instancedetails) == 0 or instancedetails[0]['InstanceState']['Name'] == '') :
    print(f'Instance with id : {instanceId} couldnt be turned on')
    ec2.stop_instances(InstanceIds=[instanceId])
    sys.exit()

instancedetails = ec2.describe_instances(InstanceIds=[instanceId])
public_IpAddress = instancedetails['Reservations'][0]['Instances'][0]['PublicIpAddress']

# function to test if the post is available on the host
def wait_ssh_port(host, port = 22, retries = 30, delay = 1) :
    for _ in range(0,retries):
        try :
            socket.create_connection((host,port), timeout=1).close()
            print("SSH Ready")
            return True
        except :
            time.sleep(delay)
    print("Port not responding ")
    return False
    
print(f'''Instance ID : {instanceId}
          Status : Running
          Checking for port availability!
''')

portavailablity = wait_ssh_port(public_IpAddress)

if portavailablity == False :
    print("Try Again")
    sys.exit()

connectUrl = 'ubuntu@'+public_IpAddress

# Connecting to instance using subprocess module
try :
    print("Press Ctrl+D for exiting out of the instance")
    subprocess.run(['ssh', '-i', 'locationofthepubkey', connectUrl])
except :
    print("Logging out and shutting the instance")

# Stopping the instance when the work is over
ec2.stop_instances(InstanceIds=[instanceId])
