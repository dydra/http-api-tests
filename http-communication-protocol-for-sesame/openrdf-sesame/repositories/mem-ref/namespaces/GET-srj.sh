#! /bin/bash

# verify syntax and header presence

curl -f -s -S -X GET \
     -H "Accept: application/sparql-results+json" \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/namespaces?auth_token=${STORE_TOKEN} \
   | json_reformat -m \
   | fgrep -i vars | fgrep -i prefix | fgrep -q -i namespace
