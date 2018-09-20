# !/usr/bin/env python
# Copyright 2017 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from __future__ import print_function
from future.standard_library import install_aliases
install_aliases()

from urllib.parse import urlparse, urlencode
from urllib.request import urlopen, Request
from urllib.error import HTTPError

#import requests
import datetime
import json
import os
import re

from flask import Flask
from flask import request
from flask import make_response
from flask import render_template

# Flask app should start in global layout
app = Flask(__name__)

#----------------------------------------Entry Point for webhook---------------------------------------------------

baseurl = "https://api.datamuse.com/words?topics=health&md=d&sp="

@app.route('/webhook', methods=['POST'])
def webhook():
    req = request.get_json(silent=True, force=True)

    print("Request:")
    print(json.dumps(req, indent=4))
    if req.get("queryResult").get("action") == "mental-health-info":
        res = processInfo(req)
    res = json.dumps(res, indent=4)

    r = make_response(res)
    print("Response:")
    print(json.dumps(res, indent=4))
    r.headers['Content-Type'] = 'application/json'
    return r



#----------------------------------------processing Funtions---------------------------------------------------
#Mental Health Info
def processInfo(req):
    if req.get("queryResult").get("action") != "mental-health-info":
        return {}
    dm_query = makeDataMuseQuery(req)
    if dm_query is None:
        return {}
    dm_url = baseurl + dm_query
    result = urlopen(dm_url).read()
    data = json.loads(result)
    res = makeWebhookResult(data)
    return res


	
# ----------------------------------------json data extraction functions---------------------------------------------------
def makeWebhookResult(data):
    fulfillmentText = 'According to datamuse.com, ' + data[0]['word'] + ' is '
    text = data[0]['defs'][0]
    fulfillmentText = fulfillmentText + re.split(r'\t+', text)[1]
    print('text: '+ fulfillmentText)
    #if data.get('response_code') == 210:
     #   speech = "Train may be cancelled or is not scheduled to run"
    return {
        "fulfillmentText": fulfillmentText,
        "source": "webhook-dm"
    }
	

	
# ------------------------------------query parameter extracting functions---------------------------------------------------
def makeDataMuseQuery(req):
    result = req.get("queryResult")
    parameters = result.get("parameters")
    disease = parameters.get("disease")
    print("disease:"+disease)
    if disease is None:
        return None
    return disease


#----------------------------------------Entry Point for chatbot---------------------------------------------------

@app.route('/chatbot')
def chatbot():
#    url = 'https://api.api.ai/v1/query?v=20150910'
#    payload = {
#    "query": "Screener", 
#    "lang": "en", 
#    "sessionId": "sessionId"
#    }
    # Adding empty header as parameters are being sent in payload
#    headers = {
#	"Authorization":"Bearer b32250b5d97f45118abbf80529249863",
#	"Content-Type":"application/json; charset=utf8"
#	}
#    r = requests.post(url, data=json.dumps(payload), headers=headers)
#    print(r.content)
    return render_template('index.html')


	
if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))

    print("Starting app on port %d" % port)

    app.run(debug=False, port=port, host='0.0.0.0')