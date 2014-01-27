#! /bin/bash


curl -f -s -S -X GET\
     -H "Accept: application/n-triples" \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?auth_token=${STORE_TOKEN} \
   | fgrep -v "{STORE_NAMED_GRAPH}" \
   | wc -l | fgrep -q 2

