#! /bin/bash

# test that a non-existent repository yields a 404


curl -w "%{http_code}\n" -f -s -X DELETE\
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}-not?auth_token=${STORE_TOKEN} \
   | fgrep -q "${STATUS_NOT_FOUND}"

