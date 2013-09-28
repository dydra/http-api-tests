#! /bin/bash


curl -w "%{http_code}\n" -f -s --head\
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | fgrep -q "${STATUS_OK}"

