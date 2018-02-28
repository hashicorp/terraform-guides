import boto3
import json
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """Returns stringified JSON output to the requestor."""
    running = json.dumps(get_running_instance_data())
    return running
    
def get_running_instances(region):
    """Checks instances in a single region for required tags, returns list of instance ids."""
    ec2 = boto3.resource('ec2',region_name=region)
    instances = ec2.instances.filter(
        Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
    instance_list = []
    for instance in instances:
        instance_list.append(instance.id)
    logger.info("Found "+str(len(instance_list))+" running instances in "+region)
    return instance_list

def get_running_instance_data():
    """
    Fetches a master list of instances across all regions, returns dictionary 
    that includes some identifying information as key-value pairs.
    """
    global_running_instances = {}
    for r in get_regions():
    #for r in ['us-east-1']:
        client = boto3.client('ec2',region_name=r)
        # Get our list of running instances
        instance_ids = get_running_instances(r)
        if len(instance_ids) != 0:
            response = client.describe_instances(InstanceIds=instance_ids)
            #logger.info(response)
            for reservation in response['Reservations']:
                for instance in reservation['Instances']:
                    # In case we have no tags, default to None
                    name = None
                    owner = None
                    ttl = None
                    created_by = None
                    if 'Tags' in instance:
                        for tag in instance['Tags']:
                            if tag['Key'] == "Name":
                                name = tag['Value']
                            if tag['Key'] == "owner":
                                owner = tag['Value']
                            if tag['Key'] == "TTL":
                                ttl = tag['Value']
                            if tag['Key'] == "created-by":
                                created_by = tag['Value']
                    # Add more data as you see fit.
                    global_running_instances[instance['InstanceId']] = {
                        'InstanceType': instance['InstanceType'],
                        'RegionName': r,
                        'LaunchTime': str(instance['LaunchTime']),
                        'State': instance['State']['Name'],
                        'KeyName': instance.get('KeyName'),
                        'Name': name,
                        'Owner': owner,
                        'TTL': ttl,
                        'created-by': created_by
                    }
    return global_running_instances
    
def get_regions():
    """Returns a list of all AWS regions."""
    c = boto3.client('ec2')
    regions = [region['RegionName'] for region in c.describe_regions()['Regions']]
    return regions

if __name__ == '__main__':
    lambda_handler({}, {})