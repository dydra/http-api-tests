#! /bin/bash

# environment :
# STORE_ACCOUNT : account name
# STORE_URL : host http url 

curl -f -s -S -X GET \
     -H "Accept: application/json" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/profile?auth_token=${STORE_TOKEN} \
   | json_reformat -m \
   | fgrep '"has_parent"' \
   | fgrep '"title":"mem-rdf"' \
   | fgrep '"homepage":{"type":"uri","value":"http://example.org/test"}' \
   | fgrep '"description":"a summary\n\na description"' \
   | fgrep -q '"license":{"type":"uri","value":"http://unlicense.org"}'