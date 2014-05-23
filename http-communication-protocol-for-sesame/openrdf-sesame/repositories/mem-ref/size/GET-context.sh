#! /bin/bash

# verify the single statement count of the named graph in the initialized repository


curl -f -s -S -X GET\
     -H "Accept: text/plain" \
     $STORE_URL/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/size?auth_token=${STORE_TOKEN}\&context=%3C${STORE_NAMED_GRAPH}%3E \
   | egrep -q '^1$'

curl -f -s -S -X GET\
     -H "Accept: text/plain" \
     $STORE_URL/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/size?auth_token=${STORE_TOKEN}\&context=%3C${STORE_NAMED_GRAPH}%3E\&context=%3Curn:dydra:default%3E \
   | egrep -q '^2$'

curl -f -s -S -X GET\
     -H "Accept: text/plain" \
     $STORE_URL/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/size?auth_token=${STORE_TOKEN}\&context=%3Curn:dydra:default%3E \
   |egrep -q '^1$'

curl -f -s -S -X GET\
     -H "Accept: text/plain" \
     $STORE_URL/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/size?auth_token=${STORE_TOKEN}\&context=null \
   |egrep -q '^1$'

curl -f -s -S -X GET\
     -H "Accept: text/plain" \
     $STORE_URL/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/size?auth_token=${STORE_TOKEN}\&context=default \
   |egrep -q '^1$'


curl -f -s -X GET \
     -H "Accept: text/plain" \
     $STORE_URL/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/size?auth_token=${STORE_TOKEN}\&context=%3C${STORE_NAMED_GRAPH}-not%3E \
   | egrep -q '^0$'

