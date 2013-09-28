#! /bin/bash


curl -w "%{http_code}\n" -f -s --head\
     -H "Accept: application/n-quads" \
     ${STORE_NAMED_GRAPH}?auth_token=${STORE_TOKEN} \
   | fgrep -q "${STATUS_OK}"

