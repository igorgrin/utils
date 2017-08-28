#!/bin/bash
# Create new Wavefront alert from a json file

# OS detection
platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
   platform='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
   platform='macos'
fi

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

# Check gsed
if [[ $platform == 'macos' ]]; then
  SED=`which gsed`
  echo $SED
  if [ -z "$SED" ]
    then
      echo "Please install gnu-sed"
      echo "brew install gnu-sed"
      exit 1
    fi
else
  SED=`which sed`
  echo $SED
fi

# Check alert id in json provided
ALERT_ID=`cat $1 |grep '"id":' |awk -F\" '{print $4}'`

if [ -z "$ALERT_ID" ]
  then
    echo "Creating Alert"
    
    # Push json and update source json with alertID
    curl -s -X POST -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $API_TOKEN" "https://okta.wavefront.com/api/v2/alert" -d @$1 | python -mjson.tool |tee /tmp/wv.log
    cat /tmp/wv.log |grep '"id":' |awk -F\" '{print $4}' | xargs -I '{}' $SED -i '1 a\ \ "id": "{}",' $1
    echo "Done"

  else
    echo "AlertId already exist in your json: $ALERT_ID"
    echo "Please run wv_update.sh instead to update an existing alert?"
fi
