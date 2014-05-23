#! /bin/bash

curl -f -s -S -X GET\
     -H "Accept: application/sparql-results+xml" \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}?'query=select%20count(*)%20where%20%7b?s%20?p%20?o%7d&'auth_token=${STORE_TOKEN} \
   | xmllint  --c14n11 - \
   | fgrep -q '<sparql'

curl -f -s -S -X GET\
     -H 'Accept: application/sparql-results+xml,application/sparql-results+json,,*/*;q=0.9' \
     $STORE_URL/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}?'query=select%20count(*)%20where%20%7b?s%20?p%20?o%7d&'auth_token=${STORE_TOKEN} \
   | xmllint  --c14n11 - \
   | fgrep -q '<sparql'

curl -f -s -S -X GET\
     -H 'Accept: application/sparql-results+json;q=0.5,application/sparql-results+xml,*/*;q=0.9' \
     $STORE_URL/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}?'query=select%20count(*)%20where%20%7b?s%20?p%20?o%7d&'auth_token=${STORE_TOKEN} \
   | xmllint  --c14n11 - \
   | fgrep -q '<sparql'
