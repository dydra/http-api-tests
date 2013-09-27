#! /bin/bash


curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN}\&default \
   | rapper -q --input nquads --output nquads \ | tr -s '\n' '\t' \
   | fgrep '"default object"' | fgrep -v -q '"named object"' 
