#! /bin/bash


curl -w "%{http_code}\n" -f -s -X GET \
     -H "Accept: application/n-triples" \
     $STORE_URL/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/rdf-graphs/service?graph=${STORE_NAMED_GRAPH}-not\&auth_token=${STORE_TOKEN} \
   | fgrep -q "404"

