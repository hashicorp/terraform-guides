import boto3
import json
import logging
import os
import csv
import io

from base64 import b64decode
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError

ENCRYPTED_HOOK_URL = os.environ['kmsEncryptedHookUrl']
SLACK_CHANNEL = os.environ['slackChannel']
HOOK_URL = boto3.client('kms').decrypt(CiphertextBlob=b64decode(ENCRYPTED_HOOK_URL))['Plaintext'].decode('utf-8')

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

lam = boto3.client('lambda')

def lambda_handler(event, context):
    message = get_instances()

    # Send the message as an attachment so we don't flood the backscroll
    slack_message = {
        'channel': SLACK_CHANNEL,
        'text': 'Untagged Instance Report',
        'attachments': [
            {
                'text': message
            }
        ]
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
        
def get_instances():
    payload = {}
    payload['key1'] = "hello"
    
    try:
        response = lam.invoke(FunctionName='getInstances',
                    InvocationType='RequestResponse',
                    Payload=json.dumps(payload))
    except Exception as e:
        print(e)
        raise e

    # Grab the payload response from the other getInstances Lambda
    # Then we have to .read() to turn it into bytes, and .decode()
    # to get it back into JSON-formatted text, and finally we wrap
    # a json.loads around it to get our JSON.
    data=json.loads(response['Payload'].read().decode())
    # Make an in memory "file" object to write to, use CSVwriter
    # to dump all our data into it.
    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerows(data)
    contents = output.getvalue()
    return(contents)