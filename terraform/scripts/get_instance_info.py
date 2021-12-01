import json
import os

state = morpheus['state']['stateList'][0]['statePath']
instance = morpheus['instance']

class instanceData(object):
    def __init__(self,instance_name,access_key,secret_key):
        self.hostname = instance_name
        self.access_key = access_key
        self.secret_key = secret_key
        
with open(state) as file:
    data = json.load(file)
    
resources = data['resources']

for i in instance['containers']:
    name = str(i['instance']['name'])
    labInstance = instanceData(hostname=name)

    for resource in resources:    
        if resource['type'] == "aws_iam_access_key":
            access = resource['instances']
            for r in access:
                if name == r['attributes']['user']:
                    labInstance.access_key = r['attributes']['id']   
                    labInstance.secret_key = r['attributes']['secret']

    print("---------------------------------------------------------------------------------------------------------------------------------------------------")
    print("Hostname: " + labInstance.hostname)
    print("Student Access Key: " + labInstance.access_key)
    print("Student Secret Key: " + labInstance.secret_key)
    print("")