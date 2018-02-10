# General purpose Lambda function for sending Slack messages, encrypted in transit.

import boto3
import json
import logging
import os
import csv
import io
from datetime import datetime,timezone,timedelta
from dateutil import parser

# Required if you want to encrypt your Slack Hook URL in the AWS console
# from base64 import b64decode
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError

SLACK_CHANNEL = os.environ['slackChannel']
# Required if you want to encrypt your Slack hook URL in the AWS Console
# ENCRYPTED_HOOK_URL = os.environ['slackHookUrl']
# HOOK_URL = boto3.client('kms').decrypt(CiphertextBlob=b64decode(os.environ['slackHookUrl']))['Plaintext'].decode('utf-8')
HOOK_URL = os.environ['slackHookUrl']

logger = logging.getLogger()
logger.setLevel(logging.INFO)

lam = boto3.client('lambda')

def lambda_handler(event, context):
    """Sends out a formatted slack message.  Edit to your liking."""
    
    msg_text = 'The Reaper Cometh :reaper:'
    tagged = get_tagged_instances()
    expired = generate_expired_dict(tagged)
    # logger.info(expired)
    
    # Create a TSV-formatted list of instances that were found
    output = io.StringIO()
    writer = csv.writer(output, delimiter='\t')
    writer.writerow(['******************************************','',''])
    writer.writerow(['The following instances will be terminated:','',''])
    writer.writerow(['Instance_Id        ', 'Region   ', 'Expires_On'])
    for key, value in expired.items():
        #value['InstanceId'] = key
        writer.writerow([key, value['RegionName'], value['ExpiresOn']])
    contents = output.getvalue()
    
    # If there are any instances on the list, notify slack.
    if expired:
        send_slack_message(
            msg_text, 
            title='Expired TTL Instance Report - TESTING',
            text="```\n"+str(contents)+"\n```",
            fallback='Expired Instance Cleanup',
            color='warning'
        )

    # Put expired TTL instances down
    for instance,data in expired.items():
        sleep_instance(instance,data['RegionName'])
    
def send_slack_message(msg_text, **kwargs):
    """Sends a slack message to the slackChannel you specify. The only parameter
    required here is msg_text, or the main message body text. If you want to 
    format your message use the attachment feature which is documented here: 
    https://api.slack.com/docs/messages.  You simply pass in your attachment 
    parameters as keyword arguments, or key-value pairs. This function currently
    only supports a single attachment for simplicity's sake.
    """
    slack_message = {
        'channel': SLACK_CHANNEL,
        'text': msg_text,
        'attachments': [ kwargs ]
    }

    req = Request(HOOK_URL, json.dumps(slack_message).encode('utf-8'))
    try:
        response = urlopen(req)
        response.read()
        logger.info("Message posted to %s", slack_message['channel'])
    except HTTPError as e:
        logger.error("Request failed: %d %s", e.code, e.reason)
    except URLError as e:
        logger.error("Server connection failed: %s", e.reason)
        
def get_tagged_instances():
    """Calls the Lambda function that returns a dictionary of instances."""
    try:
        response = lam.invoke(FunctionName='getTaggedInstances', InvocationType='RequestResponse')
    except Exception as e:
        print(e)
        raise e
    return response
    
def generate_expired_dict(response):
    """Generates a dictionary of instances that have passed their Time to Live (TTL)."""
    data = json.loads(response['Payload'].read().decode('utf-8'))
    data = json.loads(data)
    expired_instances = {}
    for key, value in data.items():
        # A value of -1 signifies that a machine should never be reaped.
        if int(value['TTL']) != -1:
            launch_time = parser.parse(value['LaunchTime'])
            expires_on = launch_time + timedelta(hours=int(value['TTL']))
            # If we have passed the expires_on time, add to list.
            if expires_on < datetime.now(timezone.utc):
                expired_instances[key] = {
                    'RegionName':value['RegionName'],
                    'Owner':value['Owner'],
                    'TTL':value['TTL'],
                    'LaunchTime':str(launch_time),
                    'ExpiresOn':str(expires_on)
                }
    return expired_instances

def sleep_instance(instance_id,region):
    ec2 = boto3.resource('ec2', region_name=region)
    """Stops instances that have gone beyond their TTL"""
    # Uncomment to make this live!
    #ec2.instances.filter(InstanceIds=instance_id).stop()
    logger.info("I would have stopped "+instance_id+" in "+region)