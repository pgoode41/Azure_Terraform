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
terraform_Variable_File="/home/${logged_in_user}/Documents/NomadAzure/Azure_Terraform/Azure/Azureterraform.tfvars"
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
    if [[ ! -e ${terraform_Variable_File} ]];then
        touch ${terraform_Variable_File}
        chown ${logged_in_user} -R ${terraform_Variable_File}
    else
        rm -rfv ${terraform_Variable_File}
        touch ${terraform_Variable_File}
        chown ${logged_in_user} -R ${terraform_Variable_File}
    fi
}

function serviceAccountCreateandShip {
    #Setting up Azure subscriptions service account.
    #Stores JSON Output In Temp Textfile For Parsing.
    az account set --subscription=${getAzure_SubscriptionId}
    az ad sp create-for-rbac \
    --role="Contributor" \
    --scopes="/subscriptions/${getAzure_SubscriptionId}" \
    > ${azureSubscriptionsSA_FULLPATH}

    #Extracts Needed Data And Stores In Script Vars.
    #jq IS Used To Parse Json.
    #sed IS Being Used To Strip Quotes.
    getAzure_appId=$(cat ${azureSubscriptionsSA_FULLPATH} | jq '.appId' | sed -e 's/^"//' -e 's/"$//')
    getAzure_password=$(cat ${azureSubscriptionsSA_FULLPATH} | jq '.password' | sed -e 's/^"//' -e 's/"$//')
    getAzure_tenantId=$(cat ${azureSubscriptionsSA_FULLPATH} | jq '.tenant' | sed -e 's/^"//' -e 's/"$//')

    #Sends Extracted Vars To .tfvars File.
    echo "client_id = "'"'${getAzure_appId}'"' >> ${terraform_Variable_File}
    echo "subscription_id = "'"'${getAzure_SubscriptionId}'"' >> ${terraform_Variable_File}
    echo "client_secret = "'"'${getAzure_password}'"' >> ${terraform_Variable_File}
    echo "tenant_id = "'"'${getAzure_tenantId}'"' >> ${terraform_Variable_File}
}
############################################################################################################################
# Script Function Zone End
############################################################################################################################

############################################################################################################################
# Script Work Zone Start
############################################################################################################################

#Execute depfilesCreate() Function. 
depfilesCreate

#Execute serviceAccountCreateandShip() Function.
serviceAccountCreateandShip


############################################################################################################################
# Script Work Zone End
############################################################################################################################


exit 0