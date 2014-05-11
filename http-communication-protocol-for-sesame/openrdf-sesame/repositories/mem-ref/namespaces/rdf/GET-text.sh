#! /bin/bash

# verify default response content type

curl -f -s -S -X GET\
     -H "Accept: text/plain" \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/namespaces/rdf?auth_token=${STORE_TOKEN} \
   | fgrep -q 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'


