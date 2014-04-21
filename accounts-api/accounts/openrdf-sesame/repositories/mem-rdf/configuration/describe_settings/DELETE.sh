#! /bin/bash



${CURL} -w "%{http_code}\n" -f -s -X DELETE \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/configuration/describeSubjectDepth?auth_token=${STORE_TOKEN} \
 | fgrep -q "204"
