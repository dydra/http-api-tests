#! /bin/bash
set -o errexit

# the protocol target is a direct graph, the content is n-quads:
# - triples are added to the document(default) graph.
# - quads are added to the document graph.
# - no statements are removed

$CURL -w "%{http_code}\n" -f -s -X POST \
     -H "Content-Type: application/n-quads" \
     --data-binary @- \
    ${STORE_NAMED_GRAPH_URL}?auth_token=${STORE_TOKEN} <<EOF \
   | egrep -q "$STATUS_POST_SUCCESS"
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST1" <${STORE_NAMED_GRAPH}-two> .
EOF


$CURL -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | egrep '"default object"' | egrep '"named object"' | egrep  "<${STORE_NAMED_GRAPH}>" \
   | egrep '"default object POST1"' | egrep '"named object POST1"' | egrep  "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | wc -l | egrep -q 4


$CURL -w "%{http_code}\n" -f -s -S -X POST \
     -H "Content-Type: application/n-quads" \
     --data-binary @- \
     ${STORE_NAMED_GRAPH_URL}?auth_token=${STORE_TOKEN} <<EOF \
  | egrep -q "$STATUS_POST_SUCCESS"
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST2" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST2" <${STORE_NAMED_GRAPH}-two> .
EOF


$CURL -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | egrep '"default object"' | egrep '"named object"' | egrep  "<${STORE_NAMED_GRAPH}>" \
   | egrep '"default object POST1"' | egrep '"named object POST1"' \
   | egrep '"default object POST2"' | egrep '"named object POST2"' | egrep  "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | wc -l | egrep -q 6

initialize_repository | egrep -q "$STATUS_POST_SUCCESS"
