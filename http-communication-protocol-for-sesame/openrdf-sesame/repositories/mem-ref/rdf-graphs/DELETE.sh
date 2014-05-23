#! /bin/bash

# add a direct sesame graph and then delete it

initialize_repository_rdf_graphs | grep_put_success

curl -f -s -S -X GET \
     $STORE_URL/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/size?auth_token=${STORE_TOKEN} \
 | fgrep -q '3'


curl -w "%{http_code}\n" -f -s -X DELETE \
     $STORE_URL/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/rdf-graphs/sesame?auth_token=${STORE_TOKEN} \
 | fgrep -q "${STATUS_DELETE_SUCCESS}"

curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?auth_token=${STORE_TOKEN} \
   | wc -l | fgrep -q 2

initialize_repository | grep_put_success

