#! /bin/bash

# write onfiguration changes as for request

${CURL}  -w "%{http_code}\n" -f -s -X PUT \
     -H "Content-Type: application/x-www-form-urlencoded" \
     --data-binary @- \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/configuration/prefixes?auth_token=${STORE_TOKEN} <<EOF \
 | fgrep -q "204"
_method=PUT&repository[prefixes]=PREFIX cc-not: <http://creativecommons.org/ns#> PREFIX xsd-not: <http://www.w3.org/2001/XMLSchema#>
EOF


${CURL}  -v -f -s -S -X GET \
     -H "Accept: application/json" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/configuration/prefixes?auth_token=${STORE_TOKEN} \
 | json_reformat -m | fgrep 'cc-not:' | fgrep 'xsd-not:' | fgrep -v -q 'xsd:'

initialize_prefixes | fgrep -q "204"
