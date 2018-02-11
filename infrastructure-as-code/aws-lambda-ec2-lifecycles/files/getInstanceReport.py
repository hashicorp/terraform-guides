# Example functions for AWS reporting. Use as a base to build your own.

import boto3
import json
import logging
import os
import csv
import io

logger = logging.getLogger()
logger.setLevel(logging.INFO)

lam = boto3.client('lambda')

def lambda_handler(event, context):
    """Generates a tab-separated list of running instances."""
    # You could also use get_tagged_instances or get_untagged_instances here
    running = get_running_instances()
    report = generate_tsv(running)
    #logger.info(report)
    return(report)

def get_running_instances():
    """Calls the Lambda function that returns a dictionary of instances."""
    try:
        response = lam.invoke(FunctionName='getRunningInstances', InvocationType='RequestResponse')
    except Exception as e:
        print(e)
        raise e
    return response
    
# This could be useful for generating email reports or dumping a list of running
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

if __name__ == '__main__':
    lambda_handler({}, {})