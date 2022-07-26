#!/usr/bin/env python3
from matrix_client.client import MatrixClient
import sys
import logging
import json
import importlib
importlib.reload(sys)
from dotenv import load_dotenv
import os
load_dotenv()

## Variables from .env
user = os.environ.get('user')
password = os.environ.get('password')
server = os.environ.get('server')
room =  os.environ.get('room')

## Matrix connection handler
client = MatrixClient(server)
token = client.login(username=user, password=password)
room = client.join_room(room)

## File handling
alert_stdin = ""
for line in sys.stdin:
    alert_stdin += line
alert_json = json.loads(alert_stdin)

## Dictionary of json objects
dict_list = {
"Message":"alert_json['message']", \
"Remediation":"alert_json['remediation']",
}

## Check dict agains json values
def dict_request(value):
    try:
        data = eval(str(value))
        return data;
    except KeyError:
        return()

### Build html message
html = "<html><head></head><body>"
for key,value in dict_list.items():
        content = dict_request(value)
        if content:
            if key == 'Remediation':
                content = str("&#x26A0"+content+"<br>")
                html=html+content
            else:
                content = str(str(content)+"<br>")
                html=html+content
html=html+"</body></html>"

## Send message
room.send_html(html, msgtype="m.notice")
logging.info('Message been sended.')

## CleanUp
dict_list.clear()
logging.info('Cleaning up. Exit.')
exit()
