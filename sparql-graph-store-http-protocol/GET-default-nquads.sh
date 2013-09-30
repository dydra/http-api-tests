#! /bin/bash


curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?default\&auth_token=${STORE_TOKEN} \
   | rapper -q --input nquads --output nquads /dev/stdin - | tr -s '\n' '\t' \
   | fgrep '"default object"' | fgrep -v -q '"named object"' 

