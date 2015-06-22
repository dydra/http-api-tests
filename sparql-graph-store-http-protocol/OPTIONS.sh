#! /bin/bash
set -o errexit

# executed for three content/accept media types,
# with expected variations in the available options

curl_graph_store_get -D - -X OPTIONS \
   | fgrep "Allow" | fgrep GET | fgrep -q DELETE

curl_graph_store_get -D - -f -s -X OPTIONS\
     -H "Content-Type: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | fgrep "Allow" | fgrep PUT | fgrep PATCH | fgrep POST | fgrep -q DELETE

curl_graph_store_get -D - -f -s -X OPTIONS\
     -H "Content-Type: application/sparql-query" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | fgrep "Allow" | fgrep POST | fgrep -q DELETE

curl_graph_store_get -D - -f -s -X OPTIONS\
     -H "Accept: application/sparql-results+xml" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | fgrep "Allow" | fgrep GET | fgrep -q DELETE
