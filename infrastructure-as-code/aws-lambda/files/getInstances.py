# This function returns a dictionary of improperly tagged or untagged instances.

# TODO: Rename as getUntaggedInstances

import boto3
import json
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """Returns stringified JSON output to the requestor."""
    untagged = json.dumps(get_untagged_instances())
    return untagged
    
def get_regions():
    """Returns a list of all AWS regions."""
    c = boto3.client('ec2')
    regions = [region['RegionName'] for region in c.describe_regions()['Regions']]
    return regions
    
def check_instance_tags(region):
    """Checks instances in a single region for mandatory tags, returns list of instance ids."""
    ec2 = boto3.resource('ec2',region_name=region)
    instances = ec2.instances.all()
    # We should be able to check against this list:
    mandatory_tags = [os.environ.get("REQTAGS").split(",")]
    naughty_list = []
    for instance in instances:
        if instance.tags:
            # There's got to be a way to compare mandatory tags vs. instance.tags
            if 'owner' not in instance.tags or 'TTL' not in instance.tags:
                naughty_list.append(instance.id)
        else:
            naughty_list.append(instance.id)
    return naughty_list

def get_untagged_instances():
    """
    Fetches a master list of untagged or improperly tagged instances across all 
    regions.  Returns a dictionary object with the instance id as the primary key.
    """
    global_untagged_instances = {}
    for r in get_regions():
    #for r in ['us-east-1']:
        client = boto3.client('ec2',region_name=r)
        # Get our list of untagged instances
        instance_ids = check_instance_tags(r)
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
                global_untagged_instances[instance['InstanceId']] = {
                    'InstanceType': instance['InstanceType'],
                    'RegionName': r,
                    'KeyName': instance.get('KeyName'),
                    'Name': name,
                    'Owner': owner,
                    'TTL': ttl,
                    'created-by': created_by
                }
    return global_untagged_instances

if __name__ == '__main__':
    lambda_handler({}, {})