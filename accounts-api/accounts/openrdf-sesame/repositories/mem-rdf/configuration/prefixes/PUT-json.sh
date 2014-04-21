#! /bin/bash

${CURL}  -w "%{http_code}\n" -f -s -X PUT \
     -H "Content-Type: application/json" \
     --data-binary @- \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/configuration/prefixes?auth_token=${STORE_TOKEN} <<EOF \
 |  fgrep -q "204"
{"prefixes": "PREFIX cc-not: <http://creativecommons.org/ns#> PREFIX xsd-not: <http://www.w3.org/2001/XMLSchema#>"}
EOF


${CURL}  -f -s -S -X GET\
     -H "Accept: application/json" \
     $STORE_URL/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/configuration/prefixes?auth_token=${STORE_TOKEN} \
 | json_reformat -m | fgrep 'cc-not:' | fgrep 'xsd-not:' | fgrep -v 'cc:' | fgrep -q -v 'xsd:'

initialize_prefixes | fgrep -q "204"
