#! /bin/bash

# remove everything but control - which should suffice to reset the metadata. but not to read the repository

${CURL} -w "%{http_code}\n"  -f -s -X POST \
  -H "Content-Type: application/json" \
  --data-binary @- \
  ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/authorization?auth_token=${STORE_TOKEN} <<EOF \
 |  egrep -q "${POST_SUCCESS}"
{"ID": {"type":"bnode", "value":"n4kfwl78"},
 "accessTo": {"type":"uri", "value":"http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf"},
 "agent": {"type":"uri", "value":"http://dydra.com/users/openrdf-sesame"},
 "mode": [{"type":"uri", "value":"http://www.w3.org/ns/auth/acl#Control"}]}
EOF

# verify that read is not possible
${CURL} -w "%{http_code}\n" -f -s -X GET \
  -H "Accept: text/csv" \
  ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?'query=select%20count(*)%20where%20%7b?s%20?p%20?o%7d&'auth_token=${STORE_TOKEN} \
 |  fgrep -q "${STATUS_UNAUTHORIZED}"



# reset
${CURL} -w "%{http_code}\n"  -f -s -X POST \
  -H "Content-Type: application/json" \
  --data-binary @- \
  ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/authorization?auth_token=${STORE_TOKEN} <<EOF \
 |  fgrep -q "204"
{"type":"uri", "value":"urn:dydra:default"}
EOF

