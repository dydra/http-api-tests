#! /bin/bash

# remove everything but control

curl -w "%{http_code}\n"  -f -s -X POST \
     -H "Content-Type: application/json" \
     --data-binary @- \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/authorization?auth_token=${STORE_TOKEN} <<EOF \
 |  egrep -q "${POST_SUCCESS}"
{"ID": {"type":"bnode", "value":"n4kfwl78"},
 "accessTo": {"type":"uri", "value":"http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf"},
 "agent": {"type":"uri", "value":"http://dydra.com/users/openrdf-sesame"},
 "mode": [{"type":"uri", "value":"http://www.w3.org/ns/auth/acl#Control"}]}
EOF


# verify that control only remains
curl -f -s -S -X GET\
     -H "Accept: application/json" \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/authorization?auth_token=${STORE_TOKEN} \
 | json_reformat -m | fgrep 'acl#Control' | fgrep -v 'acl#Read' | fgrep -q -v 'acl#Write'


# reset
${CURL} -w "%{http_code}\n"  -f -s -X POST \
     -H "Content-Type: application/json" \
     --data-binary @- \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/authorization?auth_token=${STORE_TOKEN} <<EOF \
 |  fgrep -q "204"
{"type":"uri", "value":"urn:dydra:default"}
EOF

