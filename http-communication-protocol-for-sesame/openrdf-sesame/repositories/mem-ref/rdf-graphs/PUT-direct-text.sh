#! /bin/bash

# verify that text/plain is processed as application/n-triples


curl -w "%{http_code}\n" -f -s -X PUT \
     -H "Content-Type: text/plain" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/rdf-graphs/sesame?auth_token=${STORE_TOKEN} <<EOF \
   | grep_put_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT1 buy w/o graph" .
EOF


curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | fgrep '"default object"' | fgrep '"named object"' | fgrep  "<${STORE_NAMED_GRAPH}>" \
   | tr -s '\t' '\n' | fgrep 'rdf-graphs/sesame' | wc -l | fgrep -q 2

initialize_repository | grep_put_success
