#!/usr/bin/env bash

if [ $# -lt 1 ]; then
  . .config
else
  . $1
fi

NAMED_CREDENTIALS_FILE='../force-app/main/default/namedCredentials/ClientCredentials.namedCredential-meta.xml'
AUTH_PROVIDER_FILE='../force-app/main/default/authproviders/ClientCredentials.authprovider-meta.xml'
CUSTOM_METADATA_FILE='../force-app/main/default/customMetadata/ClientCredentials_Metadata.ClientCredentials.md-meta.xml'
REMOTE_SITE_FILE='../force-app/main/default/remoteSiteSettings/clientCredentials.remoteSite-meta.xml'

# set Named Credential
sed -i '' -e "s!<endpoint>.*</endpoint>!<endpoint>${ENDPOINT}</endpoint>!" ${NAMED_CREDENTIALS_FILE}

# set executer of AuthProvider
sed -i '' -e "s!<executionUser>.*</executionUser>!<executionUser>${EXECUTION_USER}</executionUser>!" ${AUTH_PROVIDER_FILE}

# set custom meta data
sed -i '' -e "/<field>Access_Token_URL__c<\/field>/{n;s!<value xsi:type=\"xsd:string\">.*</value>!<value xsi:type=\"xsd:string\">${ACCESS_TOKEN_URL}</value>!;}" ${CUSTOM_METADATA_FILE}
sed -i '' -e "/<field>Client_ID__c<\/field>/{n;s!<value xsi:type=\"xsd:string\">.*</value>!<value xsi:type=\"xsd:string\">${CLIENT_ID}</value>!;}" ${CUSTOM_METADATA_FILE}
sed -i '' -e "/<field>Client_Secret__c<\/field>/{n;s!<value xsi:type=\"xsd:string\">.*</value>!<value xsi:type=\"xsd:string\">${CLIENT_SECRET}</value>!;}" ${CUSTOM_METADATA_FILE}
sed -i '' -e "/<field>User_Name__c<\/field>/{n;s!<value xsi:type=\"xsd:string\">.*</value>!<value xsi:type=\"xsd:string\">${EXECUTION_USER}</value>!;}" ${CUSTOM_METADATA_FILE}

# set remote site
sed -i '' -e "s!<url>.*</url>!<url>${REMOTE_SITE_URL}</url>!" ${REMOTE_SITE_FILE}