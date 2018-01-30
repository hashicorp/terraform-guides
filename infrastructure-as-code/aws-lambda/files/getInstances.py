import boto3
import json
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    # This client is only for fetching a list of regions.
    c = boto3.client('ec2')
    regions = [region['RegionName'] for region in c.describe_regions()['Regions']]
    #logger.info(regions)
    big_list = []
    for r in regions:
        # Need a new client here for each region, because we are iterating.
        client = boto3.client('ec2',region_name=r)
        instance_ids = check_instances(r)
        response = client.describe_instances()
        for reservation in response["Reservations"]:
            for instance in reservation["Instances"]:
                id = instance["InstanceId"]
                keyname = instance.get("KeyName")
                az = instance["Placement"]["AvailabilityZone"]
                big_list.append([r,id,keyname])
    return big_list

def check_instances(region):
    ec2 = boto3.resource('ec2',region_name=region)
    instances = ec2.instances.all()
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