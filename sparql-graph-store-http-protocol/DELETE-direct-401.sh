#! /bin/bash


# test that improper authentication yields a 401

curl -w "%{http_code}\n" -f -s -X DELETE \
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN}-not \
   | fgrep -q "${STATUS_UNAUTHORIZED}"

