#! /bin/bash

${CURL} -X GET \
     -w "%{http_code}\n" -f -s \
     -H "Accept: application/json" \
     $STORE_URL/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/configuration/describeForm?auth_token=${STORE_TOKEN} \
  | json_reformat -m \
  | fgrep 'describeForm' \
  | fgrep -q "/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}"

