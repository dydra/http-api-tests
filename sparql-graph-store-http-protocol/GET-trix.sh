#! /bin/bash

curl -f -s -S -X GET \
     -H "Accept: application/trix" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | rapper -q --input nquads --output nquads /dev/stdin - | tr -s '\n' '\t' \
   | fgrep -v "<${STORE_NAMED_GRAPH}>" \
   | fgrep '"default object"' | fgrep -q '"named object"' 
