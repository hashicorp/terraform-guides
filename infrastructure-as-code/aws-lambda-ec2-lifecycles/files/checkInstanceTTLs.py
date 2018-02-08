# General purpose Lambda function for sending Slack messages, encrypted in transit.

import boto3
import json
import logging
import os
import csv
import io
from collections import Counter

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
    
    # msg_text = 'The Reaper Cometh :reaper:'
    # expired = generate_expired_dict(tagged)
    tagged = get_tagged_instances()
    return tagged
    
    # send_slack_message(
    #     msg_text, 
    #     title='AWS Instance Reaper Report :reaper:',
    #     text="```\n"+lb+"\n```",
    #     fallback='AWS Instance Reaper Report :reaper:',
    #     color='warning'
    # )
    
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
        expired_instances[key] = expired_instances[value['TTL']]
    logger.info(expired_instances)
    return expired_instances

# This could be useful for generating email reports or dumping a list of untagged
# instances into an S3 bucket.
def generate_tsv(response):
    """Ingests data from a lambda response, converts it to tab-separated format."""
    data=json.loads(response['Payload'].read().decode('utf-8'))
    data=json.loads(data)
    output = io.StringIO()
    writer = csv.writer(output, delimiter='\t')
    for key, value in data.items():
        value['InstanceId'] = key
        writer.writerow(value.values())
    contents = output.getvalue()
    return(contents)