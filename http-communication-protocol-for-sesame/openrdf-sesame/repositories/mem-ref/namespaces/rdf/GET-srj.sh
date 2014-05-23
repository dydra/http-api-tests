#! /bin/bash

# verify response content type limits

curl -f -s -X GET \
     -H "Accept: application/sparql-results+json" \
     $STORE_URL/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/namespaces/rdf?auth_token=${STORE_TOKEN} \
   | json_reformat -m \
   | fgrep -q "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
