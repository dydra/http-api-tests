#! /bin/bash

# the protocol target is an indirect graph, the statements include quads and the content type is n-quads:
# - triples are added to the document (default) graph.
# - quads are added to the document graph.
# - statements would be removed from the target graph only, but there are none
# that is, the effect is the same as for POST

$CURL -w "%{http_code}\n" -f -s -S -X PUT \
     -H "Content-Type: application/n-quads" \
     --data-binary @- \
     ${STORE_NAMED_GRAPH_URL}-three?auth_token=${STORE_TOKEN} <<EOF \
   | egrep -q "$STATUS_PUT_SUCCESS"
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT1" <${STORE_NAMED_GRAPH}-two> .
EOF


$CURL -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | egrep '"default object"' | egrep '"named object"' | egrep  "<${STORE_NAMED_GRAPH}>" \
   | egrep '"default object PUT1"' | egrep '"named object PUT1"' | egrep  "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | wc -l | egrep -q 4


$CURL -w "%{http_code}\n" -f -s -S -X PUT \
     -H "Content-Type: application/n-quads" \
     --data-binary @- \
     ${STORE_NAMED_GRAPH_URL}-three?auth_token=${STORE_TOKEN} <<EOF \
   | egrep -q "$STATUS_PUT_SUCCESS"
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT2" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT2" <${STORE_NAMED_GRAPH}-two> .
EOF


$CURL -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | egrep '"default object"' | egrep '"named object"' | egrep  "<${STORE_NAMED_GRAPH}>" \
   | egrep '"default object PUT1"' | egrep '"named object PUT1"' \
   | egrep '"default object PUT2"' | egrep '"named object PUT2"' | egrep  "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | wc -l | egrep -q 6

initialize_repository | egrep -q "$STATUS_PUT_SUCCESS"
