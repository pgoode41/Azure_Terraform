#!/bin/bash


############################################################################################################################
# This Script Extracts Azure Provider Needed For TerraForm.
# After Extracting, It Also Builds A .tfvars File For Use.
############################################################################################################################

############################################################################################################################
# Script Variable Zone Start
############################################################################################################################
#Gets Azure Subscription ID From Az CLI.
getAzure_SubscriptionId=$(az account show |  jq '.id')
subScriptionFormated=$(az account show |  jq '.id' | sed -e 's/^"//' -e 's/"$//')
azureSubscriptionServiceAccount_DIR="/tmp/AzureSA_Info"
azureSubscriptionServiceAccount_FILE="ServiceAccountInfo.txt"
azureSubscriptionsSA_FULLPATH="${azureSubscriptionServiceAccount_DIR}/${azureSubscriptionServiceAccount_FILE}"
logged_in_user=$(who | awk '{print$1}')
tf_VariableFile="/home/${logged_in_user}/Documents/NomadAzure/Azure_Terraform/Azure/Azureterraform.tfvars"
packerFile="/home/${logged_in_user}/Documents/NomadAzure/Azure_Terraform/Azure/packerFile.json"





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
        rm -rfv ${azureSubscriptionServiceAccount_DIR} 
    fi
    mkdir ${azureSubscriptionServiceAccount_DIR}
    touch ${azureSubscriptionsSA_FULLPATH}
    chown ${logged_in_user} -R ${azureSubscriptionsSA_FULLPATH}

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
    

    
    subScriptionFormated=$(az account show |  jq '.id' | sed -e 's/^"//' -e 's/"$//')
    az account set --subscription="${subScriptionFormated}"    
    az ad sp create-for-rbac \
    --name="${subScriptionFormated}-azvm-serviceaccount-v2" \
    --role="Contributor" \
    --scopes="/subscriptions/${subScriptionFormated}" \
    > ${azureSubscriptionsSA_FULLPATH}
}

function serviceAccount_Store {
    #Extracts Needed Data And Stores In Script Vars.
    #jq IS Used To Parse Json.

    #sed IS Being Used To StripQuotes.
    getAzure_appId=$(cat ${azureSubscriptionsSA_FULLPATH} | jq '.appId' | sed -e 's/^"//' -e 's/"$//')
    getAzure_password=$(cat ${azureSubscriptionsSA_FULLPATH} | jq '.password' | sed -e 's/^"//' -e 's/"$//')
    getAzure_tenantId=$(cat ${azureSubscriptionsSA_FULLPATH} | jq '.tenant' | sed -e 's/^"//' -e 's/"$//')

    #Sends Extracted Vars To .tfvars File.
    echo "client_id = "'"'${getAzure_appId}'"' > ${tf_VariableFile}
    echo "subscription_id = ${getAzure_SubscriptionId}" >> ${tf_VariableFile}
    echo "client_secret = "'"'${getAzure_password}'"' >> ${tf_VariableFile}
    echo "tenant_id = "'"'${getAzure_tenantId}'"' >> ${tf_VariableFile}
    cat ${tf_VariableFile} | grep 'subscription_id' | awk '{print$3}' | sed -e 's/^"//' -e 's/"$//'
}


function packerBuildVars {
    #Pulls Azure Subscription vars for packer json to user. 
    packer build \
    -var-file="packer_AzProviderInfo.json" \
    ${packerFile}
}

function terraformAuto {
    terraform init -input=false
    terraform plan -var-file=Azureterraform.tfvars -out=tfplan -input=false
    terraform apply -input=false tfplan
}    
############################################################################################################################
# Script Function Zone End
############################################################################################################################

############################################################################################################################
# Script Work Zone Start
############################################################################################################################


if [[ $(az ad sp list --all| grep "${subScriptionFormated}-azvm-serviceaccount-v2" | grep 'displayName' | awk '{print$2}') != '"'${subScriptionFormated}-azvm-serviceaccount-v2'"', ]];then
    #Execute depfilesCreate() Function. 
    depfilesCreate
    #Execute serviceAccount_Create() Function.
    serviceAccount_Create
    #Execute serviceAccount_Store() Function.
    serviceAccount_Store
    echo "no match"
    else
        echo "matched"
fi

#Execute packerBuildVars() Function.
packerBuildVars

#Generates .tf server files
python3 serverDynamo.py

#Generates Provisioner info for packer to consumer.
#This syncs to Provisioner Vars and creates a Json file that matches.
python3 packer_AzProviderInfo_Generator.py

#Builds and Image for a chef-server.
packer build -var-file="packer_AzProviderInfo.json" chefServer_Image.json

#Automatically Inits, Plans and Applies Terraform Plan.
#Uses tfvars file.
terraformAuto

############################################################################################################################
# Script Work Zone End
############################################################################################################################


exit 0