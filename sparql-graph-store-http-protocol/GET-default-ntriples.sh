#! /bin/bash

curl_graph_store_get -H "Accept: application/n-triples" "default" \
   | rapper -q --input ntriples --output ntriples /dev/stdin - | tr -s '\n' '\t' \
   | fgrep '"default object"' | fgrep -v -q '"named object"' 


#curl -L -v -f -s -S -X GET \
#     -H "Accept: application/n-triples" \ ; 
#     -u "${STORE_TOKEN}:" \
#     "http://dydra.com/jhacker/foaf/service?default"
