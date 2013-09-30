#! /bin/bash

curl -f -s -S -X GET \
     -H "Accept: text/x-graphviz" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | fgrep -q 'digraph' 
