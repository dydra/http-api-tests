#! /bin/bash

# verify operation of an html view

SPARQL_URL="${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/all.html" \
curl_sparql_request  -X GET | egrep -q '<title>.* openrdf-sesame/mem-rdf</title>'

#echo $SPARQL_URL
#echo
