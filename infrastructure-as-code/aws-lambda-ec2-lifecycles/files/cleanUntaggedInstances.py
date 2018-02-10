# This function deals with instances that are untagged.  Use the environment variables 
# SLEEPDAYS and REAPDAYS to set your lifecycle policies.

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

SLEEPDAYS = os.environ['sleepDays']
REAPDAYS = os.environ['reapDays']

logger = logging.getLogger()
logger.setLevel(logging.INFO)

lam = boto3.client('lambda')

def lambda_handler(event, context):
    """Sleeps instances after SLEEPDAYS and terminates them after REAPDAYS. Times are measured beginning from LaunchDate."""
    
    msg_text = 'Enter the Sandman :sleeping:'
    untagged = get_untagged_instances()
    stop_dict = generate_stop_dict(untagged)
    terminate_dict = generate_terminate_dict(untagged)

    # Stop instances that have passed SLEEPDAYS.
    for instance,data in stop_dict.items():
        sleep_instance(instance,data['RegionName'])

    # Terminate instances that have passed REAPDAYS.
    for instance,data in terminate_dict.items():
        terminate_instance(instance,data['RegionName'])
    
    # Create a TSV-formatted list of instances scheduled for stop or termination
    output = io.StringIO()
    writer = csv.writer(output, delimiter='\t')
    writer.writerow(['*********************************************', '', ''])
    writer.writerow(['These instances will be put to sleep:', '', ''])
    writer.writerow(['Instance_Id        ', 'Region   ', 'stop_on'])
    for key, value in stop_dict.items():
        #value['InstanceId'] = key
        writer.writerow([key, value['RegionName'], value['StopOn']])
    writer.writerow(['*********************************************', '', ''])
    writer.writerow(['These instances will be terminated:', '', ''])
    writer.writerow(['Instance_Id        ', 'Region   ', 'stop_on'])
    for key, value in terminate_dict.items():
        #value['InstanceId'] = key
        writer.writerow([key, value['RegionName'], value['TerminateOn']])
    contents = output.getvalue()
    
    # If there are any instances on the list, notify slack.
    if contents:
        send_slack_message(
            msg_text, 
            title='Untagged Instance Report - TESTING',
            text="```\n"+str(contents)+"\n```",
            fallback='Untagged Instance Report - TESTING',
            color='warning'
        )
    
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
        
def get_untagged_instances():
    """Calls the Lambda function that returns a dictionary of instances."""
    try:
        response = lam.invoke(FunctionName='getUntaggedInstances', InvocationType='RequestResponse')
    except Exception as e:
        print(e)
        raise e
    return response
    
def generate_stop_dict(response):
    """Generates a dictionary of untagged instances to stop."""
    data = json.loads(response['Payload'].read().decode('utf-8'))
    data = json.loads(data)
    stop_instances = {}
    for key, value in data.items():
        launch_time = parser.parse(value['LaunchTime'])
        stop_on = launch_time + timedelta(days=int(SLEEPDAYS))
        # If we have passed the stop_on time, add to list.
        if stop_on < datetime.now(timezone.utc):
            stop_instances[key] = {
                'RegionName':value['RegionName'],
                'Owner':value['Owner'],
                'TTL':value['TTL'],
                'LaunchTime':str(launch_time),
                'StopOn':str(stop_on)
            }
    return stop_instances

def generate_terminate_dict(response):
    """Generates a dictionary of untagged instances to terminate."""
    data = json.loads(response['Payload'].read().decode('utf-8'))
    data = json.loads(data)
    terminate_instances = {}
    for key, value in data.items():
        # A value of -1 signifies that a machine should never be reaped.
        launch_time = parser.parse(value['LaunchTime'])
        terminate_on = launch_time + timedelta(days=int(SLEEPDAYS))
        # If we have passed the terminate_on time, add to list.
        if terminate_on < datetime.now(timezone.utc):
            terminate_instances[key] = {
                'RegionName':value['RegionName'],
                'Owner':value['Owner'],
                'TTL':value['TTL'],
                'LaunchTime':str(launch_time),
                'TerminateOn':str(terminate_on)
            }
    return terminate_instances

def sleep_instance(instance_id,region):
    """Stops instances that have gone beyond their TTL"""
    # Uncomment to make this live!
    #ec2 = boto3.resource('ec2', region_name=region)
    #ec2.instances.filter(InstanceIds=instance_id).stop()
    logger.info("I would have stopped "+instance_id+" in "+region)

def terminate_instance(instance_id,region):
    """Stops instances that have gone beyond their TTL"""
    # Uncomment to make this live!
    #ec2 = boto3.resource('ec2', region_name=region)
    #ec2.instances.filter(InstanceIds=instance_id).terminate()
    logger.info("I would have terminated "+instance_id+" in "+region)