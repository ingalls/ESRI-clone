#/usr/bin/env bash

OLDIFS=$IFS
set -e -o pipefail

# Usage: filesafe "filename"
# Returns a valid file/folder name
function _filesafe() {
  if [[ -z $1 ]]; then exit 1; fi
  echo $(echo "$1" | sed -e 's/[^A-Za-z0-9._-]/_/g')
}

function getListing() {
    echo "# Listing Folders ($1)"
    local LIST=$(curl -s "$1?f=pjson")
    local SERVICES=$(echo $LIST | jq -r -c '.services | .[]')
    local FOLDERS=$(echo $LIST | jq -r -c '.folders | .[]')

    for FOLDER in $FOLDERS; do
        mkdir $DATADIR/$SITEDIR/$(echo $1 | sed 's/.*rest\/services//') || true
        getListing "$BASE/$FOLDER"
    done

    for SERVICE in $SERVICES; do
        case "$(echo $SERVICE | jq  -r -c '.type')" in
            GPServer)
                echo "# GPServer not supported!"
            ;;
            MapServer)
                getMapServer "$BASE/$(echo $SERVICE | jq  -r -c '.name')/$(echo $SERVICE | jq  -r -c '.type')"
            ;;
            *)
                echo "# $(echo $SERVICE | jq  -r -c '.type') not supported"
            ;;
        esac
    done
}

function getMapServer() {
    echo "# Listing Services ($1)"
    local LAYERS=$(curl -s "$1?f=pjson" | jq -r -c '.layers | .[]')
    for LAYER in $LAYERS; do
        echo "# Dumping Layer ($1/$(echo $LAYER | jq -r -c '.id'))"
        esri-dump "$1/$(echo $LAYER | jq -r -c '.id')"
    done
    exit 1
}




if [[ -z $1 ]]; then
    echo "Usage ./get.js [URL]"
    exit 1
fi

BASE=$(echo "$1" | grep -o ".*\/rest\/services")
DATADIR=$(echo $(dirname $0)/data)
SITEDIR=$(_filesafe $(echo $BASE | grep -Po "[A-Z|a-z]+?\.[a-z]{2,3}\/" | sed 's/\..*//'))

echo "# creating site directory"
mkdir -p $DATADIR/$SITEDIR || true
getListing $BASE
