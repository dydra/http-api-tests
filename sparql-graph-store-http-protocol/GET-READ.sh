#! /bin/bash

# verify read access for user with read access only

curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-byuser?auth_token=${STORE_TOKEN}_READ \
   | rapper -q --input nquads --output nquads /dev/stdin - | tr -s '\n' '\t' \
   | fgrep -q "<http://example.com/subject>"
