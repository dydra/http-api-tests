#! /bin/bash

# test that improper authentication yields a 401


curl -w "%{http_code}\n" -f -s --head\
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY} \
   | fgrep -q "${STATUS_UNAUTHORIZED}"
