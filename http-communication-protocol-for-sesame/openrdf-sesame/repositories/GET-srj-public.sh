#! /bin/bash

if $STORE_CLIENT_IP_AUTHORIZED
then
curl -f -s -S -X GET\
     -H "Accept: application/sparql-results+json" \
     $STORE_URL/${STORE_ACCOUNT}/repositories \
   | json_reformat -m \
   | fgrep '"value":"mem-rdf-anon"' \
   | fgrep -q '"value":"mem-rdf-readbyip"' 

else
curl -f -s -S -X GET\
     -H "Accept: application/sparql-results+json" \
     $STORE_URL/${STORE_ACCOUNT}/repositories \
   | json_reformat -m \
   | fgrep -q '"value":"mem-rdf-anon"' 
fi 
