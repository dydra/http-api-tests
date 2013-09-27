#! /bin/bash


curl -w "%{http_code}\n" -f -s -X GET\
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-not?auth_token=${STORE_TOKEN} \
   | fgrep -q "${STATUS_NOT_FOUND}"

