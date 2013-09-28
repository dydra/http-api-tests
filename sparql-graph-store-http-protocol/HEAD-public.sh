#! /bin/bash


curl -w "%{http_code}\n" -f -s --head\
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY_PUBLIC} \
   | fgrep -q "${STATUS_OK}"

