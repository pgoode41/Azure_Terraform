import sys
import os 
import json
import string
from pprint import pprint

with open("config.json") as j:
    json = json.load(j)


servers = json['Servers']
openText = open("ServerTemplate.txt", 'r')
text = openText.readlines()


for x in servers:
    serverName = servers[x][0]['name']
    project = servers[x][0]['project']
    with open("ServerTemplate.txt") as f:
        newText=f.read().replace('@=', serverName)
    with open("ServerFile_"+serverName+".tf","w+") as f:
        f.write(newText)