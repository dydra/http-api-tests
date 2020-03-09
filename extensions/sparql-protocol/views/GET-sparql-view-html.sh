#! /bin/bash

# verify operation of an html view

SPARQL_URL="${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/all.html" \
curl_sparql_request  -X GET -H "Accept:" | egrep -q '<title>.*'${STORE_ACCOUNT}/${STORE_REPOSITORY}'.*</title>'

#echo $SPARQL_URL
#echo
