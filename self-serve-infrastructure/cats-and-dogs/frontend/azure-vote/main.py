from flask import Flask, request, render_template
import os
import random
import redis
import socket
import sys
import hvac
import json

app = Flask(__name__)

# Load configurations
app.config.from_pyfile('config_file.cfg')
button1 =       app.config['VOTE1VALUE']
button2 =       app.config['VOTE2VALUE']
title =         app.config['TITLE']

# Vault configuration
try:
    client = hvac.Client(url=os.environ['VAULT_ADDR'])
    params = {'role':'demo', 'jwt':os.environ['K8S_TOKEN']}
    result = client.auth('/v1/auth/' + os.environ['VAULT_K8S_BACKEND'] + 'login', json=params)
    print(result)

    # Redis configurations
    redis_server = os.environ['REDIS']
    cats_and_dogs = client.read('secret/' + os.environ['VAULT_USER'] + '/kubernetes/cats-and-dogs')
    print(cats_and_dogs)
    redis_pwd = cats_and_dogs['data']['redis_pwd']
    print("redis password is: " + redis_pwd)
except:
    exit("Could not get secrets from Vault")

# Redis Connection
try:
   if redis_pwd:
        r = redis.StrictRedis(host=redis_server,
                        port=6379,
                        password=redis_pwd)
   else:
        r = redis.StrictRedis(redis_server)
   r.ping()
except redis.ConnectionError:
   exit('Failed to connect to Redis, terminating.')

# Change title to host name to demo NLB
if app.config['SHOWHOST'] == "true":
    title = socket.gethostname()

# Init Redis
if not r.get(button1): r.set(button1,0)
if not r.get(button2): r.set(button2,0)

@app.route('/', methods=['GET', 'POST'])
def index():

    if request.method == 'GET':

        # Get current values
        vote1 = r.get(button1).decode('utf-8')
        vote2 = r.get(button2).decode('utf-8')

        # Return index with values
        return render_template("index.html", value1=int(vote1), value2=int(vote2), button1=button1, button2=button2, title=title)

    elif request.method == 'POST':

        if request.form['vote'] == 'reset':

            # Empty table and return results
            r.set(button1,0)
            r.set(button2,0)
            vote1 = r.get(button1).decode('utf-8')
            vote2 = r.get(button2).decode('utf-8')
            return render_template("index.html", value1=int(vote1), value2=int(vote2), button1=button1, button2=button2, title=title)

        else:

            # Insert vote result into DB
            vote = request.form['vote']
            r.incr(vote,1)

            # Get current values
            vote1 = r.get(button1).decode('utf-8')
            vote2 = r.get(button2).decode('utf-8')

            # Return results
            return render_template("index.html", value1=int(vote1), value2=int(vote2), button1=button1, button2=button2, title=title)

if __name__ == "__main__":
    app.run()
