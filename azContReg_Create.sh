#!/bin/bash

#az group create --name myResourceGroup --location eastus

resourceGroup='DefaultResourceGroup-EUS'
registryName='azcontainerTestRepo'
defaultDockerImg='ubuntu'
aksUbuntuBaseName='aksUbuntuBase'


#LeaveBlank
acrLoginServer=''

az acr create \
--resource-group ${resourceGroup} \
--name ${registryName} \
--sku Basic

az acr login \
--name ${registryName}

acrLoginServer=$(az acr list \
--resource-group ${resourceGroup} \
--query "[].{acrLoginServer:loginServer}" \
| jq '.[] | .acrLoginServer' \
| sed -e 's/^"//' -e 's/"$//') > ${acrLoginServer}

echo ${acrLoginServer}

docker pull ${defaultDockerImg}
docker tag ${defaultDockerImg} ${acrLoginServer}/${defaultDockerImg}:v1
docker images 

