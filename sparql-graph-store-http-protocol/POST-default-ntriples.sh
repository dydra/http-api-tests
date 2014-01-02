#! /bin/bash
set -o errexit

# the protocol target is the default graph, the statements include quads and the content type is n-triples:
# - triples are added to the protocol (default) graph.
# - quads are added to the protocol (default) graph.
# - no statements are removed

$CURL -w "%{http_code}\n" -f -s -S -X POST \
     -H "Content-Type: application/n-triples" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?default\&auth_token=${STORE_TOKEN} <<EOF \
   | egrep -q "$STATUS_POST_SUCCESS"
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST1" <${STORE_NAMED_GRAPH}-two> .
EOF


$CURL -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | egrep '"default object"' | egrep '"named object"' | egrep '"default object PUT1"' | egrep '"named object PUT1"' \
   | egrep "<${STORE_NAMED_GRAPH}>" | egrep -v "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | wc -l | egrep -q 4


initialize_repository | egrep -q "$STATUS_POST_SUCCESS"
