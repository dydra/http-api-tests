#! /bin/bash

# cycle the prefixes to test success
# environment :
# STORE_ACCOUNT : account name
# STORE_URL : host http url 
# STORE_REPOSITORY : individual repository

${CURL} -w "%{http_code}\n"  -f -s -X POST \
     -H "Content-Type: application/json" \
     --data-binary @- \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/configuration?auth_token=${STORE_TOKEN} <<EOF \
 |  fgrep -q "204"
{"type":"uri", "value":"http://www.w3.org/1999/02/22-rdf-syntax-ns#nil"}
EOF

${CURL} -f -s -S -X GET\
     -H "Accept: application/json" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/configuration?auth_token=${STORE_TOKEN} \
 | fgrep -q  '{}'

initialize_repository_configuration | fgrep -q "204"

${CURL} -f -s -S -X GET\
     -H "Accept: application/json" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/prefixes?auth_token=${STORE_TOKEN} \
 | json_reformat -m | fgrep '"cc":"http://creativecommons.org/ns#"' | fgrep -q 'xsd":"http://www.w3.org/2001/XMLSchema#"'
