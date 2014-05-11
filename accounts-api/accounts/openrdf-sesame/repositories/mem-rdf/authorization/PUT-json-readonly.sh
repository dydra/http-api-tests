#! /bin/bash

# remove write access - which should suffice to read the repository but not to update it

${CURL} -w "%{http_code}\n"  -f -s -X POST \
     -H "Content-Type: application/json" \
     --data-binary @- \
     ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/authorization?auth_token=${STORE_TOKEN} <<EOF \
 |  egrep -q "${POST_SUCCESS}"
{"ID": {"type":"bnode", "value":"n4kfwl78"},
 "accessTo": {"type":"uri", "value":"http://dydra.com/accounts/openrdf-sesame/repositories/mem-rdf"},
 "agent": {"type":"uri", "value":"http://dydra.com/users/openrdf-sesame"},
 "mode": [{"type":"uri", "value":"http://www.w3.org/ns/auth/acl#Control"},
          {"type":"uri", "value":"http://www.w3.org/ns/auth/acl#Read"}]}
EOF



# verify that read is possible
${CURL} -w "%{http_code}\n" -f -s -X GET \
 -H "Accept: text/csv" \
 ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?'query=select%20count(*)%20where%20%7b?s%20?p%20?o%7d&'auth_token=${STORE_TOKEN} \
 |  fgrep -q "${STATUS_OK}"

# but write is not
# INSERT DATA {<http://example.com/subject> <http://example.com/predicate> "object" . }
${CURL} -w "%{http_code}\n" -f -s -X GET \
 -H "Accept: text/csv" \
 ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?'query=INSERT%20DATA%20%7B%3Chttp%3A%2F%2Fexample.com%2Fsubject%3E%20%3Chttp%3A%2F%2Fexample.com%2Fpredicate%3E%20%22object%22%20.%20%7D&'auth_token=${STORE_TOKEN} \
 |  fgrep -q "${STATUS_UNAUTHORIZED}"


# reset
${CURL} -w "%{http_code}\n"  -f -s -X POST \
 -H "Content-Type: application/json" \
 --data-binary @- \
 ${STORE_URL}/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/authorization?auth_token=${STORE_TOKEN} <<EOF \
 |  fgrep -q "204"
{"type":"uri", "value":"urn:dydra:default"}
EOF

