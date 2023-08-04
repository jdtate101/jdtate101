#!/bin/bash

mydomain="kodu.uk"
myhostname="@"
gdapikey="e4MzvNDEGarF_31NoFzfBXbvkSHMxUeWZNK:FHtjcK7N9eQ6VqhXDWRMM9"
logdest="local7.info"

myip=`curl -s "https://api.ipify.org"`

gdip=`echo $dnsdata | cut -d ',' -f 1 | tr -d '"' | cut -d ":" -f 2`
echo "`date '+%Y-%m-%d %H:%M:%S'` - Current External IP is $myip, GoDaddy DNS IP is $gdip"

if [ "$gdip" != "$myip" -a "$myip" != "" ]; then
  echo "IP has changed!! Updating on GoDaddy"
  curl -s -X PUT "https://api.godaddy.com/v1/domains/${mydomain}/records/A/${myhostname}" -H "Authorization: sso-key ${gdapikey}" -H "Content-Type: application/json" -d "[{\"data\": \"${myip}\"}]"
  logger -p $logdest "Changed IP on ${hostname}.${mydomain} from ${gdip} to ${myip}"
fi
