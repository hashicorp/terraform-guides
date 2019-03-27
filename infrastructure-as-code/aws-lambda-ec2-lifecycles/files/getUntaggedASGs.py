# Gets a list of untagged ASGs and returns some info about them.

import boto3
import json
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """Returns stringified JSON output to the requestor."""
    untagged = json.dumps(get_untagged_asgs())
    #logger.info("I found "+str(len(get_untagged_asgs()))+" untagged asgs in this account.")
    return untagged
    
def check_asg_tags(region):
    """Checks asgs in a single region for required tags, returns list of asg ids."""
    client = boto3.client('autoscaling',region_name=region)
    asgs = client.describe_auto_scaling_groups()['AutoScalingGroups']
    # We should be able to check against this list:
    mandatory_tags = os.environ.get("REQTAGS").split(",")
    naughty_list = []
    for asg in asgs:
        if asg['Tags']:
            #logger.info(asg['Tags'])
            taglist = []
            for tag in asg['Tags']:
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
                naughty_list.append(asg['AutoScalingGroupName'])
        else:
            naughty_list.append(asg['AutoScalingGroupName'])
    logger.info("Found "+str(len(naughty_list))+" untagged asgs in "+region)
    return naughty_list

def get_untagged_asgs():
    """
    Fetches a master list of asgs across all regions, returns dictionary 
    that includes some identifying information as key-value pairs.
    """
    global_untagged_asgs = {}
    for r in get_regions():
        client = boto3.client('autoscaling',region_name=r)
        # Get our list of untagged asgs
        asg_ids = check_asg_tags(r)
        #logger.info(asg_ids)
        if len(asg_ids) != 0:
            asgs = client.describe_auto_scaling_groups(AutoScalingGroupNames=asg_ids)['AutoScalingGroups']
            #logger.info(asgs)
            for asg in asgs:
                # In case we have no tags, default to None
                name = None
                owner = None
                ttl = None
                created_by = None
                if asg['Tags']:
                    for tag in asg['Tags']:
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
                global_untagged_asgs[asg['AutoScalingGroupName']] = {
                    'asgName': asg['AutoScalingGroupName'],
                    'RegionName': r,
                    'LaunchTime': str(asg['CreatedTime']),
                    'Owner': owner,
                    'TTL': ttl
                }
    return global_untagged_asgs
    
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