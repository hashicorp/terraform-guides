# This function deals with instances that are untagged.  Use the environment variables 
# sleepDays and reapDays to set your lifecycle policies.

import boto3
import json
import logging
import os
import csv
import io
from datetime import datetime,timezone,timedelta
from dateutil import parser
from distutils.util import strtobool

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
ISACTIVE = os.environ['isActive']

logger = logging.getLogger()
logger.setLevel(logging.INFO)

lam = boto3.client('lambda')

def lambda_handler(event, context):
    """Sleeps instances after SLEEPDAYS and terminates them after REAPDAYS. Times are measured beginning from LaunchDate."""
    
    msg_text = 'Enter the Sandman :sleeping:'
    untagged = get_untagged_instances()
    stop_dict = generate_stop_dict(untagged)
    
    untagged2 = get_untagged_instances()
    terminate_dict = generate_terminate_dict(untagged2)
    
    # Create a TSV-formatted list of instances scheduled for stop or termination
    output = io.StringIO()
    writer = csv.writer(output, delimiter='\t')
    writer.writerow(['*********************************************', '', ''])
    writer.writerow(['These instances will be put to sleep:', '', ''])
    writer.writerow(['Instance_Id        ', 'Region   ', 'Stop_On'])
    for key, value in stop_dict.items():
        writer.writerow([key, value['RegionName'], value['StopOn']])
    writer.writerow(['*********************************************', '', ''])
    writer.writerow(['These instances will be terminated:', '', ''])
    writer.writerow(['Instance_Id        ', 'Region   ', 'Terminate_On'])
    for key, value in terminate_dict.items():
        writer.writerow([key, value['RegionName'], value['TerminateOn']])
    contents = output.getvalue()

    if str_to_bool(ISACTIVE) == False:
        title_text = ':broom: Untagged Janitor - TESTING MODE'
    else:
        title_text = ':broom: Untagged Janitor - ACTIVE MODE'
    
    send_slack_message(
        msg_text, 
        title=title_text,
        text="```\n"+str(contents)+"\n```",
        fallback='Untagged Instance Report',
        color='warning'
    )
    
    # Stop instances that have passed SLEEPDAYS.
    for instance,data in stop_dict.items():
        sleep_instance(instance,data['RegionName'])

    # Terminate instances that have passed REAPDAYS.
    for instance,data in terminate_dict.items():
        terminate_instance(instance,data['RegionName'])
    
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
        # Only proceed if the instance is running
        if value['State'] == 'running':
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
    #logger.info(data)
    terminate_instances = {}
    for key, value in data.items():
        # A value of -1 signifies that a machine should never be reaped.
        launch_time = parser.parse(value['LaunchTime'])
        terminate_on = launch_time + timedelta(days=int(REAPDAYS))
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

# TODO: Move these into a central file and import them
def str_to_bool(string):
    return bool(strtobool(str(string)))

def sleep_instance(instance_id,region):
    ec2 = boto3.resource('ec2', region_name=region)
    """Stops instances"""
    if str_to_bool(ISACTIVE) == True:
        try:
            # Uncomment to make this live!
            #ec2.instances.filter(InstanceIds=[instance_id]).stop()
            logger.info("I stopped "+instance_id+" in "+region)
        except Exception as e:
            logger.info("Problem stopping instance: "+instance_id)
            logger.info(e)
    else:
        logger.info("I would have stopped "+instance_id+" in "+region)

def terminate_instance(instance_id,region):
    ec2 = boto3.resource('ec2', region_name=region)
    """Terminates instances"""
    if str_to_bool(ISACTIVE) == True:
        try:
            # Uncomment to make this live!
            #ec2.instances.filter(InstanceIds=[instance_id]).terminate()
            logger.info("I terminated "+instance_id+" in "+region)
        except Exception as e:
            logger.info("Problem terminating instance: "+instance_id)
            logger.info(e)
    else:
        logger.info("I would have terminated "+instance_id+" in "+region)
    
def isInteger(s):
    try: 
        int(s)
        return True
    except ValueError:
        return False

if __name__ == '__main__':
    lambda_handler({}, {})