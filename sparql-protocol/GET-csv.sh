#! /bin/bash


${CURL} -f -s -X GET \
       -H "Accept: text/csv" \
       ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?'query=select%20count(*)%20where%20%7b?s%20?p%20?o%7d&'auth_token=${STORE_TOKEN} \
 | tr -s '\n' '\t' \
 | egrep -q -s 'COUNT1.*1'

