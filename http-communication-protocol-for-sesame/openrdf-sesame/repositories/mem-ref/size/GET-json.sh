#! /bin/bash

# verify response content type limits

curl -f -s -X GET\
     -H "Accept: application/sparql-results+json" \
     $STORE_URL/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/size?auth_token=${STORE_TOKEN} \
   | jq '.results.bindings[] | .SIZE.value' \
   | fgrep -q '"2"'


