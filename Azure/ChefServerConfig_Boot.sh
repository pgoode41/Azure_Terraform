#!/bin/bash

############################################################################################
# This Script Will Install Chef Server On a VM
# This is Designed to be baked into a packer image and used to build a single chef server.
# Run this as a packer bootscript, that runs when the imgage is being created.
# Do Not Run This as a bootup script directly on the node you are configuring for use!
############################################################################################

function chef-Server_Install {
    #Set ChefCreds
    chefCreds_UserName='chefadmin'
    chefCreds_FirstName='chef'
    chefCreds_LastName='admin'
    chefCreds_Email='pgoode41@gmail.com'
    chefCreds_Password='souse.assonant.vest.urolog'
    #This Directory Needs TO Be Baked Into The Image Directly!
    chefCreds_KeyDirPath='/Chef_Key'
    chefOrg_OrgName='stratushook'
    chefOrg_OrgKeyDirPath="${chefCreds_KeyDirPath}/${chefOrg_OrgName}"

    chef-server_Deb="/home/preston/Documents/Chef-Server-Download/chef-server-core_12.18.14-1_amd64.deb"


    #Creating Admin Organization Path.
    if [[ ! -d "${chefOrg_OrgKeyDirPath}" ]];then
        mkdir "${chefOrg_OrgKeyDirPath}"
    fi

    # Install Chef-Server From Local Repo.
    # We will need to host this file remotely.
    # Chef Doen't Provide a direct download.
    dpkg -i ${chef-server_Deb}
    #Start SChef-Server Services.
    chef-server-ctl reconfigure


    chef-server-ctl user-create \
    ${chefCreds_UserName} \
    ${chefCreds_FirstName} \
    ${chefCreds_LastName} \
    EMAIL ${chefCreds_Password} \
    --filename ${chefCreds_KeyDirPath}/${chefCreds_UserName}.pem


    chef-server-ctl org-create \
    ${chefOrg_OrgName} ${chefOrg_OrgName} \
    --association_user ${chefCreds_UserName} \
    --filename ${chefOrg_OrgKeyDirPath}/${chefOrg_OrgName}.pem
}

apt update -y 
#Install Chef-Server
chef-Server_Install

apt update -y 
apt install python3 -y
apt install golang-go -y



exit 0 