import boto3
import json
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    instances = get_global_list()
    return instances

def get_global_list():
    """Fetches a master list of instances across all regions, returns some identifying information."""
    global_list = []
    for r in get_regions():
        client = boto3.client('ec2',region_name=r)
        instance_ids = check_instances(r)
        response = client.describe_instances()
        for reservation in response["Reservations"]:
            for instance in reservation["Instances"]:
                id = instance["InstanceId"]
                keyname = instance.get("KeyName")
                az = instance["Placement"]["AvailabilityZone"]
                global_list.append([r,id,keyname])
    return global_list
    
def get_regions():
    """Returns a list of all AWS regions."""
    c = boto3.client('ec2')
    regions = [region['RegionName'] for region in c.describe_regions()['Regions']]
    return regions

def check_instances(region):
    """Checks instances in a single region for required tags."""
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
    return json.dumps(naughty_list)

if __name__ == '__main__':
    lambda_handler({}, {})