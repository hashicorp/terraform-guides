# General purpose Lambda function for sending Slack messages, encrypted in transit.

import boto3
import json
import logging
import os
import csv
import io
from collections import Counter

from base64 import b64decode
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError

ENCRYPTED_HOOK_URL = os.environ['kmsEncryptedHookUrl']
SLACK_CHANNEL = os.environ['slackChannel']
HOOK_URL = boto3.client('kms').decrypt(CiphertextBlob=b64decode(ENCRYPTED_HOOK_URL))['Plaintext'].decode('utf-8')

logger = logging.getLogger()
logger.setLevel(logging.INFO)

lam = boto3.client('lambda')

def lambda_handler(event, context):
    msg_text = 'Hello humans. Some of you have not tagged your AWS instances yet.'
    response = get_untagged_instances()
    # csv_report = generate_csv(response)
    lb = generate_leaderboard(response)
    
    send_slack_message(
        msg_text, 
        title='The Wall Of Shame :shame: :bell:',
        text="```"+lb+"```",
        fallback='The Wall of Shame :shame: :bell:',
        color='warning',
        actions = [
            {
                "type": "button",
                "text": "Clean up my stuff",
                "url": "https://console.aws.amazon.com/ec2/v2/home"
            }
        ]
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
    """Calls the Lambda function that returns a list of instances."""
    payload = {}
    payload['key1'] = "hello"
    
    try:
        response = lam.invoke(FunctionName='getInstances',
                    InvocationType='RequestResponse',
                    Payload=json.dumps(payload))
    except Exception as e:
        print(e)
        raise e
    return response

def generate_csv(response):
    data=json.loads(response['Payload'].read().decode())
    output = io.StringIO()
    writer = csv.writer(output, delimiter='\t')
    writer.writerows(data)
    contents = output.getvalue()
    return(contents)
    
def generate_leaderboard(response):
    data=json.loads(response['Payload'].read().decode())
    keys = [item[2] for item in data]
    leaders = dict(Counter(keys))
    tmp = io.StringIO()
    writer = csv.writer(tmp, delimiter='\t')
    #writer.writerow(['Instances','Keyname'])
    count=0
    for key, value in sorted(leaders.items(), key=lambda x: x[1], reverse=True):
        if count < 15:
            writer.writerow([value, key])
        count = count + 1
    leaderboard = tmp.getvalue()
    #logger.info(leaderboard)
    return(leaderboard)