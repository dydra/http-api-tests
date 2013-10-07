#! /bin/bash


curl -f -s -S -X GET\
     -H "Accept: text/plain" \
     $STORE_URL/${STORE_ACCOUNT}/protocol \
 | fgrep -q '6'


