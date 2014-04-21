#! /bin/bash

# test validity constraint
# environment :
# STORE_ACCOUNT : account name
# STORE_URL : host http url 
# STORE_REPOSITORY : individual repository

${CURL} -X PUT \
     -w "%{http_code}\n" -f -s \
     -H "Content-Type: application/json" \
     --data-binary @- \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/configuration/describeForm?auth_token=${STORE_TOKEN} <<EOF \
 | fgrep -q 400
{"describeForm":"urn:rdfcache:simple-symmetric-concise-bounded-description-not"}
EOF

${CURL} -X PUT \
     -w "%{http_code}\n" -f -s \
     -H "Content-Type: application/json" \
     --data-binary @- \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/configuration/describeObjectDepth?auth_token=${STORE_TOKEN} <<EOF \
 | fgrep -q 400
{"describeObjectDepth":"a"}
EOF


${CURL} -X PUT \
     -w "%{http_code}\n" -f -s \
     -H "Content-Type: application/json" \
     --data-binary @- \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/configuration/describeSubjectDepth?auth_token=${STORE_TOKEN} <<EOF \
 | fgrep -q 400
{"describeSubjectDepth":"a"}
EOF
