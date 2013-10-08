#! /bin/bash

# the protocol target is an indirect graph, the statements include quads and the content type is n-triples:
# - triples are added to the protocol graph.
# - quads are added to the protocol graph.
# - statements are retained the second time in the protocol graph

curl -w "%{http_code}\n" -f -s -S -X POST \
     -H "Content-Type: application/n-triples" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?context\&auth_token=${STORE_TOKEN} <<EOF \
   | fgrep -q "${POST_SUCCESS}"
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST1" <${STORE_NAMED_GRAPH}-two> .
EOF


curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     $STORE_URL/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | fgrep '"default object"' | fgrep '"named object"' | fgrep  "<${STORE_NAMED_GRAPH}>" \
   | fgrep '"default object POST1"' | fgrep '"named object POST1"' | fgrep -v "<${STORE_NAMED_GRAPH}-two>" \
   | fgrep 'urn:uuid' \
   | tr -s '\t' '\n' | wc -l | fgrep -q 4


initialize_repository | fgrep -q "${POST_SUCCESS}"
