#! /bin/bash

# verify NO read access for user with write access only

curl -w "%{http_code}\n" -f -s -X GET\
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-byuser?auth_token=${STORE_TOKEN}_WRITE \
   | fgrep -q "${STATUS_UNAUTHORIZED}"
