#!/bin/bash

# Check argument
if [ -z "$1" ]
  then
    echo "Please supply a json file"
    echo "$0 yourfile.json"
    exit 1
fi

# Check token
if [ -z "$API_TOKEN" ]
  then
    echo "Is your API_TOKEN env variable setup?"
    exit 1
fi

# grep alert id from json provided
ALERT_ID=`cat $1 |grep '"id":' |awk -F\" '{print $4}'`

# Check alert id
if [ -z "$ALERT_ID" ]
  then
    echo "Can't find alert id in your json file"
    exit 1
fi

echo "Updating Alert $ALERT_ID"

curl -s -X PUT -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $API_TOKEN" "https://okta.wavefront.com/api/v2/alert/$ALERT_ID" -d @$1

echo -e "\nDone"
