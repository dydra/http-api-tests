#! /bin/bash

curl -f -s -S -X GET \
     -H "Accept: application/sparql-query+graphviz" \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}?'query=select%20count(*)%20where%20%7b?s%20?p%20?o%7d&'auth_token=${STORE_TOKEN} \
 | fgrep -q digraph


