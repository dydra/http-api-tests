#! /bin/bash

# test that a non-existent named graph yields a 404


curl -w "%{http_code}\n" -f -s -X DELETE\
     -H "Accept: application/n-quads" \
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN}\&graph=${STORE_NAMED_GRAPH}-not \
  | fgrep -q "${STATUS_NOT_FOUND}"
