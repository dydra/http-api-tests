#! /bin/bash


curl -w "%{http_code}\n" -f -s -S -X GET\
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN}\&graph=${STORE_NAMED_GRAPH}-not \
 | fgrep -q "${STATUS_NOT_FOUND}"

