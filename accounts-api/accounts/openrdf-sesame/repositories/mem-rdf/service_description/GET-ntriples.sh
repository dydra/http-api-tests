#! /bin/bash

curl -f -s -S -X GET\
     -H "Accept: application/n-triples" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/service-description?auth_token=${STORE_TOKEN} \
  | rapper -q --input nquads --output nquads /dev/stdin - \
  | fgrep -q "http://www.w3.org/ns/sparql-service-description#Service"

