#! /bin/bash

# the protocol target is an indirect graph, the statements include quads and the content type is n-triples:
# - triples are added to the protocol graph.
# - quads are added to the protocol graph.
# - statements are removed the second time from the protocol graph

curl -w "%{http_code}\n" -f -s -S -X PUT \
     -H "Content-Type: application/n-triples" \
     --data-binary @- \
     ${STORE_NAMED_GRAPH}-three\&auth_token=${STORE_TOKEN} <<EOF \
  | fgrep -q "${PUT_SUCCESS}"
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT1" <${STORE_NAMED_GRAPH}-two> .
EOF


curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | fgrep '"default object"' | fgrep '"named object"' | fgrep  "<${STORE_NAMED_GRAPH}>" \
   | fgrep -v "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | fgrep "${STORE_NAMED_GRAPH}-three" | wc -l | fgrep -q 2


curl -w "%{http_code}\n" -f -s -S -X PUT \
     -H "Content-Type: application/n-triples" \
     --data-binary @- \
     ${STORE_NAMED_GRAPH}-three\&auth_token=${STORE_TOKEN} <<EOF \
  | fgrep -q "${PUT_SUCCESS}"
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT2" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT2" <${STORE_NAMED_GRAPH}-two> .
EOF

curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | fgrep '"default object"' | fgrep '"named object"' | fgrep  "<${STORE_NAMED_GRAPH}>" \
   | fgrep -v "<${STORE_NAMED_GRAPH}-two>" | fgrep -v "PUT1" \
   | fgrep '"default object PUT2"' | fgrep '"named object PUT2"' \
   | tr -s '\t' '\n' | fgrep "${STORE_NAMED_GRAPH}-three" | wc -l | fgrep -q 2

initialize_repository | fgrep -q "${PUT_SUCCESS}"
