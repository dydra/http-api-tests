#! /bin/bash

# context=%3C${STORE_NAMED_GRAPH}%3E yields just the named graph content
# accept both with '<>' and withut

curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     $STORE_URL/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?context=${STORE_NAMED_GRAPH}\&auth_token=${STORE_TOKEN} \
   | wc -l | fgrep -q 1


curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     $STORE_URL/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?context=%3C${STORE_NAMED_GRAPH}%3E\&auth_token=${STORE_TOKEN} \
   | wc -l | fgrep -q 1
