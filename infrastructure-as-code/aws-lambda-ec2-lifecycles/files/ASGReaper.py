# This function uses the getTaggedASGs.py function to fetch a list of properly tagged ASGs.
# It will then determine whether those ASGs have expired, and delete them if they have.
# Finally a message is sent to Slack or Email to notify your admins.

import boto3
from botocore.exceptions import ClientError
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
ISACTIVE = os.environ['isActive']

############################################################################
# These settings are only required if you are using email for notifications.
SENDER = "Cleanup Bot <robot@example.com>"
RECIPIENT = "robot@example.com"
AWS_REGION = "us-west-2"
CHARSET = "UTF-8"
############################################################################

logger = logging.getLogger()
logger.setLevel(logging.INFO)
lam = boto3.client('lambda')

def lambda_handler(event, context):
    """Sends out a formatted slack message.  Edit to your liking."""
    
    msg_text = 'ASG Reaper Bot'
    tagged = get_tagged_asgs()
    #logger.info(tagged)
    expired = generate_expired_dict(tagged)
    #logger.info(expired)
    
    # Create a TSV-formatted list of ASGs that were found
    output = io.StringIO()
    writer = csv.writer(output, delimiter='\t')
    writer.writerow(['******************************************','',''])
    writer.writerow(['The following ASGs will be terminated:','',''])
    writer.writerow(['ASG Name'.ljust(22), 'Region   ', 'Expires_On'])
    for key, value in expired.items():
        #value['ASGId'] = key
        writer.writerow([key.ljust(22), value['RegionName'], value['ExpiresOn']])
    contents = output.getvalue()

    if str_to_bool(ISACTIVE) == False:
        title_text = ':reaper: ASG Reaper - TESTING MODE'
    else:
        title_text = ':reaper: ASG Reaper - ACTIVE MODE'

    # If there are any asgs on the list, notify slack.
    if expired:
        send_slack_message(
            msg_text, 
            title=title_text,
            text="```\n"+str(contents)+"\n```",
            fallback='Expired ASG Cleanup',
            color='warning'
        )
    else:
        logger.info("No expired ASGs to reap.")

        # Uncomment send_email to use email instead of slack
        # send_email(
        #     SENDER,
        #     RECIPIENT,
        #     AWS_REGION,
        #     title_text,
        #     contents,
        #     CHARSET
        # )

    # Put expired TTL asgs down
    for asg,data in expired.items():
        terminate_asg(asg,data['RegionName'])
    
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

def send_email(sender,recipient,aws_region,subject,body_text,charset):
    """
    Sends a plaintext email to the address of your choice. Be sure to 
    verify your email in the SES control panel first. More documentation 
    here: https://docs.aws.amazon.com/ses/latest/DeveloperGuide/send-using-sdk-python.html
    """

    # Create a new SES resource and specify a region.
    client = boto3.client('ses',region_name=aws_region)
    
    # Try to send the email.
    try:
        #Provide the contents of the email.
        response = client.send_email(
            Destination={
                'ToAddresses': [
                    recipient,
                ],
            },
            Message={
                'Body': {
                    'Text': {
                        'Charset': charset,
                        'Data': body_text,
                    },
                },
                'Subject': {
                    'Charset': charset,
                    'Data': subject,
                },
            },
            Source=sender
        )
    # Display an error if something goes wrong.	
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        print("Email sent! Message ID:"),
        print(response['ResponseMetadata']['RequestId'])

def get_tagged_asgs():
    """Calls the Lambda function that returns a dictionary of asgs."""
    try:
        response = lam.invoke(FunctionName='getTaggedASGs', InvocationType='RequestResponse')
    except Exception as e:
        print(e)
        raise e
    return response
    
def generate_expired_dict(response):
    """Generates a dictionary of asgs that have passed their Time to Live (TTL)."""
    data = json.loads(response['Payload'].read().decode('utf-8'))
    data = json.loads(data)
    expired_asgs = {}
    for key, value in data.items():
        # A value of -1 signifies that a machine should never be reaped.
        if int(value['TTL']) != -1 and isInteger(value['TTL']):
            launch_time = parser.parse(value['LaunchTime'])
            expires_on = launch_time + timedelta(hours=int(value['TTL']))
            # If we have passed the expires_on time, add to list.
            if expires_on < datetime.now(timezone.utc):
                expired_asgs[key] = {
                    'RegionName':value['RegionName'],
                    'Owner':value['Owner'],
                    'TTL':value['TTL'],
                    'LaunchTime':str(launch_time),
                    'ExpiresOn':str(expires_on)
                }
    return expired_asgs

# TODO: Move these into a central file and import them
def str_to_bool(string):
    return bool(strtobool(str(string)))

def terminate_asg(asg_name,region):
    """Terminates asgs"""
    if str_to_bool(ISACTIVE) == True:
        try:
            client = boto3.client('autoscaling',region_name=region)
            response = client.delete_auto_scaling_group(AutoScalingGroupName=asg_name, ForceDelete=True)
            logger.info(response)
            logger.info("I terminated "+asg_name+" in "+region)
        except Exception as e:
            logger.info("Problem terminating asg: "+asg_name)
            logger.info(e)
    else:
        logger.info("I would have terminated "+asg_name+" in "+region)
    
def isInteger(s):
    try: 
        int(s)
        return True
    except ValueError:
        return False

if __name__ == '__main__':
    lambda_handler({}, {})