#! /bin/bash

# cycle the prefixes to test success
# environment :
# STORE_ACCOUNT : account name
# STORE_URL : host http url 
# STORE_REPOSITORY : individual repository

${CURL} -w "%{http_code}\n"  -f -s -X POST \
     -H "Content-Type: application/json" \
     --data-binary @- \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/authorization?auth_token=${STORE_TOKEN} <<EOF \
 |  fgrep -q "204"
{"type":"uri", "value":"urn:dydra:default"}
EOF

${CURL} -f -s -S -X GET\
     -H "Accept: application/json" \
     $STORE_URL/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/authorization?auth_token=${STORE_TOKEN} \
   | json_reformat -m \
   | fgrep '"accessTo"' \
   | fgrep '"agent"' \
   | fgrep '"mode"' \
   | fgrep -q "/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}"
