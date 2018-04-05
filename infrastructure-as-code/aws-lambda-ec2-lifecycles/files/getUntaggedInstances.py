import boto3
import json
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """Returns stringified JSON output to the requestor."""
    untagged = json.dumps(get_untagged_instances())
    #logger.info("I found "+str(len(get_untagged_instances()))+" untagged instances in this account.")
    return untagged
    
def check_instance_tags(region):
    """Checks instances in a single region for required tags, returns list of instance ids."""
    ec2 = boto3.resource('ec2',region_name=region)
    instances = ec2.instances.all()
    # We should be able to check against this list:
    mandatory_tags = os.environ.get("REQTAGS").split(",")
    naughty_list = []
    for instance in instances:
        if instance.tags:
            # logger.info(instance.tags)
            taglist = []
            for tag in instance.tags:
                # Ensures that TTL is valid
                if tag['Key'] == 'TTL' or tag['Key'] == 'ttl':
                    if isInteger(tag['Value']):
                        taglist.append(tag['Key'].upper())
                elif tag['Key'] == 'Owner' or tag['Key'] == 'owner':
                    taglist.append(tag['Key'].lower())
                else:
                    taglist.append(tag['Key'])
            if set(mandatory_tags).issubset(set(taglist)):
                pass
            else:
                naughty_list.append(instance.id)
        else:
            naughty_list.append(instance.id)
    logger.info("Found "+str(len(naughty_list))+" untagged instances in "+region)
    return naughty_list

def get_untagged_instances():
    """
    Fetches a master list of instances across all regions, returns dictionary 
    that includes some identifying information as key-value pairs.
    """
    global_untagged_instances = {}
    for r in get_regions():
    #for r in ['us-east-1']:
        client = boto3.client('ec2',region_name=r)
        # Get our list of untagged instances
        instance_ids = check_instance_tags(r)
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
                            if tag['Key'] == "owner" or tag['Key'] == "Owner":
                                owner = tag['Value']
                            if tag['Key'] == "TTL" or tag['Key'] == "ttl":
                                if isInteger(tag['Value']):
                                    ttl = tag['Value']
                                else:
                                    logger.info("Invalid TTL found: "+tag['Value'])
                                    ttl = 'None'
                            if tag['Key'] == "created-by":
                                created_by = tag['Value']
                    # Add more data as you see fit.
                    global_untagged_instances[instance['InstanceId']] = {
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
    return global_untagged_instances
    
def get_regions():
    """Returns a list of all AWS regions."""
    c = boto3.client('ec2')
    regions = [region['RegionName'] for region in c.describe_regions()['Regions']]
    return regions
    
def isInteger(s):
    try: 
        int(s)
        return True
    except ValueError:
        return False

if __name__ == '__main__':
    lambda_handler({}, {})