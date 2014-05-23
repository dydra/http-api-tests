#! /bin/bash

# perform deletion, after which the retrieval has no content, but with a success code

${CURL} -w "%{http_code}\n" -f -s -S -X DELETE \
     $STORE_URL/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?context=%3C${STORE_NAMED_GRAPH}%3E\&auth_token=${STORE_TOKEN} \
   | fgrep -q "${DELETE_SUCCESS}"


curl -f -s -S -X GET \
     -H "Accept: application/n-quads" \
     $STORE_URL/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?auth_token=${STORE_TOKEN} \
   | wc -l | fgrep -q "1"


initialize_repository | grep_put_success