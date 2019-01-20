import sys
import os
import re

def tfvarsProvParse(tfvarsFilePath, packervarsFilePath):
    #Parses .tfvars file values to use in packer vars json.
    #Provide .tfvars file path to parse from and packervars file path to generate.
    with open(tfvarsFilePath, "r") as tfvarsFile:
        contents = tfvarsFile.read()
        split = contents.split('"')
        az_client_id = split[1]
        az_subscription_id = split[3]
        az_client_secret = split[5]
        az_tenant_id = split[7]



    json = {"client_id": az_client_id,
    "client_secret": az_client_secret,
    "tenant_id": az_tenant_id,
    "subscription_id": az_subscription_id}

    jsonString = str(json)
    jsonString_Formatted = jsonString.replace("'", '"')


    packerJsonFile = open(packervarsFilePath,"w")
    packerJsonFile.write(jsonString_Formatted)


tfvarsProvParse("Azureterraform.tfvars", "packer_AzProviderInfo.json")