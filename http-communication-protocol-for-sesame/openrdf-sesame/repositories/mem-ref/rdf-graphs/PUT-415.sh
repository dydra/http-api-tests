#! /bin/bash

# verify that text/plain is processed as application/n-triples only


curl -w "%{http_code}\n" -f -s -X PUT \
     -H "Content-Type: text/plain" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/rdf-graphs/sesame?auth_token=${STORE_TOKEN} <<EOF \
   | egrep -q -v "${STATUS_PUT_SUCCESS}"
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT1" <${STORE_NAMED_GRAPH}-two> .
EOF

# just in case
initialize_repository | grep_put_success
