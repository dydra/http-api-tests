#! /bin/bash


${CURL} -f -s -S -X GET\
     -H "Accept: application/json" \
     $STORE_URL/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/authorization?auth_token=${STORE_TOKEN} \
   | json_reformat -m \
   | fgrep '"accessTo"' \
   | fgrep '"agent"' \
   | fgrep '"mode"' \
   | fgrep -q "/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}"

