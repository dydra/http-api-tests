#! /bin/bash

# verify that all are read/write access

touch $$.json
trap "rm $$.json" EXIT

curl -f -s -S -X GET\
     -H "Accept: application/sparql-results+json" \
     $STORE_URL/${STORE_ACCOUNT}/repositories?auth_token=${STORE_TOKEN}  \
   | json_reformat -m > $$.json

cat $$.json | jq '.results.bindings[] | (.id.value + "," + (.readable|tostring) + "," + (.writable|tostring))' \
   | fgrep -q 'true,true'

cat $$.json | jq '.results.bindings[] | (.id.value + "," + (.readable|tostring) + "," + (.writable|tostring))' \
   | fgrep -v -q 'false'
