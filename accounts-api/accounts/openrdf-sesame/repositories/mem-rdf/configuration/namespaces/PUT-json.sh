#! /bin/bash

# cycle the prefixes to test success
# environment :
# STORE_ACCOUNT : account name
# STORE_URL : host http url 
# STORE_REPOSITORY : individual repository

curl -w "%{http_code}\n" -f -s -X PUT \
     -H "Content-Type: application/json" \
     --data-binary @- \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/configuration/namespaces?auth_token=${STORE_TOKEN} <<EOF \
 |  fgrep -q "204"
{"prefixes":{"cc-not":"http://creativecommons.org/ns#","xsd-not":"http://www.w3.org/2001/XMLSchema#"}}
EOF


curl -f -s -S -X GET\
     -H "Accept: application/json" \
     $STORE_URL/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/configuration/namespaces?auth_token=${STORE_TOKEN} \
 | json_reformat -m | fgrep 'cc-not:' | fgrep -v 'cc:' | fgrep 'xsd-not:' | fgrep -q -v 'xsd:'

initialize_prefixes | fgrep -q "204"
