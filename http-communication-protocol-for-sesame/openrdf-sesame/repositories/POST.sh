#! /bin/bash

# post to create a repository
${CURL} -w "%{http_code}\n"  -f -s -X POST \
     -H "Content-Type: application/json" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories?auth_token=${STORE_TOKEN} <<EOF \
 |  fgrep -q "204"
{"repository": {"name": "new"} }
EOF

${CURL} -f -s -S -X GET\
     -H "Accept: application/sparql-results+json" \
     $STORE_URL/${STORE_ACCOUNT}/repositories?auth_token=${STORE_TOKEN} \
   | json_reformat -m \
   | fgrep -q '"value":"new"'

${CURL} -f -s -S -X GET\
     -H "Accept: application/json" \
     $STORE_URL/${STORE_ACCOUNT}/repositories?auth_token=${STORE_TOKEN} \
   | json_reformat -m \
   | fgrep -q '"value":"new"'