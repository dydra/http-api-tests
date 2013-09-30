#! /bin/bash


curl -f -s -S -X GET\
     -H "Accept: application/n-triples" \
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}?graph=${STORE_NAMED_GRAPH}\&auth_token=${STORE_TOKEN} \
   | rapper -q --input nquads --output nquads /dev/stdin - | tr -s '\n' '\t' \
   | fgrep -v "<${STORE_NAMED_GRAPH}>" \
   | fgrep -v '"default object"' | fgrep -q '"named object"' 

