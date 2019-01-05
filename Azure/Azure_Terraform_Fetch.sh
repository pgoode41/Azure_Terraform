#!/bin/bash


############################################################################################################################
# This Script Extracts Azure Provider Needed For TerraForm.
# After Extracting, It Also Builds A .tfvars File For Use.
############################################################################################################################

############################################################################################################################
# Script Variable Zone Start
############################################################################################################################
#Gets Azure Subscription ID From Az CLI.
getAzure_SubscriptionId=$(az account show |  jq '.id' | sed -e 's/^"//' -e 's/"$//')
azureSubscriptionServiceAccount_DIR="/tmp/AzureSA_Info"
azureSubscriptionServiceAccount_FILE="ServiceAccountInfo.txt"
azureSubscriptionsSA_FULLPATH="${azureSubscriptionServiceAccount_DIR}/${azureSubscriptionServiceAccount_FILE}"
logged_in_user=$(who | awk '{print$1}')
tf_VariableFile="/home/${logged_in_user}/Documents/NomadAzure/Azure_Terraform/Azure/Azureterraform.tfvars"
packerFile="/home/${logged_in_user}/Documents/NomadAzure/Azure_Terraform/Azure/packerFile.json"
dqStripper=$(sed -e 's/^"//' -e 's/"$//')
############################################################################################################################
# Script Variable Zone End
############################################################################################################################

############################################################################################################################
# Script Function Zone Start
############################################################################################################################
function depfilesCreate {
    #Creates Temp File To Hold Service Account Json.
    #Removes if Already Exists.
    if [[ -d ${azureSubscriptionServiceAccount_DIR} ]];then
        rm -rfv ${azureSubscriptionServiceAccount_DIR} > null
    fi
    mkdir ${azureSubscriptionServiceAccount_DIR}
    touch ${azureSubscriptionsSA_FULLPATH}

    #Creates .tfvars File To Store Extracted Vars.
    #Removes if Already Exists.
    if [[ ! -e ${tf_VariableFile} ]];then
        touch ${tf_VariableFile}
        chown ${logged_in_user} -R ${tf_VariableFile}
    else
        rm -rfv ${tf_VariableFile}
        touch ${tf_VariableFile}
        chown ${logged_in_user} -R ${tf_VariableFile}
    fi
}

function serviceAccount_Create {
    #Setting up Azure subscriptions service account.
    #Stores JSON Output In Temp Textfile For Parsing.
    az account set --subscription=${getAzure_SubscriptionId}
    az ad sp create-for-rbac \
    --role="Contributor" \
    --scopes="/subscriptions/${getAzure_SubscriptionId}" \
    > ${azureSubscriptionsSA_FULLPATH}
}

function serviceAccount_Store {
    #Extracts Needed Data And Stores In Script Vars.
    #jq IS Used To Parse Json.
    #sed IS Being Used To Strip Quotes.
    getAzure_appId=$(cat ${azureSubscriptionsSA_FULLPATH} | jq '.appId' | ${dqStripper})
    getAzure_password=$(cat ${azureSubscriptionsSA_FULLPATH} | jq '.password' | ${dqStripper})
    getAzure_tenantId=$(cat ${azureSubscriptionsSA_FULLPATH} | jq '.tenant' | ${dqStripper})

    #Sends Extracted Vars To .tfvars File.
    echo "client_id = "'"'${getAzure_appId}'"' >> ${tf_VariableFile}
    echo "subscription_id = "'"'${getAzure_SubscriptionId}'"' >> ${tf_VariableFile}
    echo "client_secret = "'"'${getAzure_password}'"' >> ${tf_VariableFile}
    echo "tenant_id = "'"'${getAzure_tenantId}'"' >> ${tf_VariableFile}
}



function packerBuildVars {
    #Pulls Azure Subscription vars for packer json to user. 
    packer build \
        -var "client_id=$(cat ${tf_VariableFile} | grep 'client_id' | awk '{print$3}' | ${dqStripper})" \
        -var "subscription_id=$(cat ${tf_VariableFile} | grep 'subscription_id' | awk '{print$3}' | ${dqStripper})" \
        -var "client_secret=$(cat ${tf_VariableFile} | grep 'client_secret' | awk '{print$3}' | ${dqStripper})" \
        -var "tenant_id=$(cat ${tf_VariableFile} | grep 'tenant_id' | awk '{print$3}' | ${dqStripper})" \
        ${packerFile}
}
############################################################################################################################
# Script Function Zone End
############################################################################################################################

############################################################################################################################
# Script Work Zone Start
############################################################################################################################

#Execute depfilesCreate() Function. 
depfilesCreate

#Execute serviceAccount_Create() Function.
serviceAccount_Create
#Execute serviceAccount_Store() Function.
serviceAccount_Store

#Execute packerBuildVars() Function.
packerBuildVars

############################################################################################################################
# Script Work Zone End
############################################################################################################################


exit 0