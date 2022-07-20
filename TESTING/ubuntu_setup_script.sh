#!/bin/bash
#EOF
export PATH=${PATH}:/usr/sbin
export endpointName="SET_ME"   #eg. "Endpoint Display Name" 
export clientID="SET_ME"       #eg. Client ID retrieved from developers.globus.org
export secret="SET_ME"         #eg. Client Secret retrieved from developers.globus.org
export email="SET_ME"          #eg. james@globus.org
export globusUsername="SET_ME" #eg. auser@gmail.com, jkube@globusid.org, jkube@uchicago.edu,etc
export yourAuthDomain="SET_ME" #eg. uchicago.edu, stjude.org, etc
export stgGatewayName="SET_ME" #eg. "POSIX Storage Gateway," "googleDriveStorageGateway," etc 
export organization="SET_ME"   #eg. ST. Jude
export collectionName="SET_ME" #eg. "St. Jude POSIX Collection," "stJudePosixCollection," etc
export collectionDescription="SET_ME" #eg. "A long form description of your Collection"
export collectionBasePath="SET_ME" #eg. "/," "/mnt/globusCollections/," etc
#EOF

#Download and install Debian package for Globus Repo
curl -LOs https://downloads.globus.org/globus-connect-server/stable/installers/repo/deb/globus-repo_latest_all.deb
sudo dpkg -i globus-repo_latest_all.deb
sudo apt-key add /usr/share/globus-repo/RPM-GPG-KEY-Globus
sudo apt update -y

#Install latest GCS
sudo apt install globus-connect-server54 -y

#Setup Endpoint
/usr/sbin/globus-connect-server endpoint setup "${endpointName}" --agree-to-letsencrypt-tos --organization "${organization}" --client-id ${clientID}  --secret ${secret} --contact-email ${email} --owner ${globusUsername}

#Deploy Node
sudo globus-connect-server node setup --client-id ${clientID} --secret ${secret}

#Log into GCS CLI
globus-connect-server login localhost

#Associate the Endpoint with your Subscription/make-managed
globus-connect-server endpoint set-subscription-id DEFAULT

#Create a POSIX storage gateway and Collection
stgGw=$(globus-connect-server storage-gateway create posix "${stgGatewayName}" --domain ${yourAuthDomain} | sed -e 's/.* //g');

#Create a POSIX Collection 
globus-connect-server collection create ${stgGw} ${collectionBasePath} "${collectionName}" --organization "${organization}" --contact-email ${email} --description "${collectionDescription}" 

