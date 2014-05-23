#! /bin/bash

# the protocol target is an indirect graph, the statements include quads and the content type is n-triples:
# - triples are added to the protocol graph.
# - quads are added to the protocol graph.
# - statements are removed the second time from the protocol graph

$CURL -w "%{http_code}\n" -f -s -S -X PUT \
     -H "Content-Type: application/n-triples" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?graph=${STORE_NAMED_GRAPH}-three\&auth_token=${STORE_TOKEN} <<EOF \
  | egrep -q "$STATUS_CREATED"
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT1" <${STORE_NAMED_GRAPH}-two> .
EOF


$CURL -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | egrep '"default object"' | egrep '"named object"' | egrep  "<${STORE_NAMED_GRAPH}>" \
   | egrep -v "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | egrep "${STORE_NAMED_GRAPH}-three" | wc -l | egrep -q 2


$CURL -w "%{http_code}\n" -f -s -S -X PUT \
     -H "Content-Type: application/n-triples" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?graph=${STORE_NAMED_GRAPH}-three\&auth_token=${STORE_TOKEN} <<EOF \
  | egrep -q "$STATUS_PUT_SUCCESS"
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT2" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT2" <${STORE_NAMED_GRAPH}-two> .
EOF

$CURL -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | egrep '"default object"' | egrep '"named object"' | egrep  "<${STORE_NAMED_GRAPH}>" \
   | egrep -v "<${STORE_NAMED_GRAPH}-two>" | egrep -v "PUT1" \
   | egrep '"default object PUT2"' | egrep '"named object PUT2"' \
   | tr -s '\t' '\n' | egrep "${STORE_NAMED_GRAPH}-three" | wc -l | egrep -q 2

initialize_repository | egrep -q "$STATUS_PUT_SUCCESS"
