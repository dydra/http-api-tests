#! /bin/bash

# the protocol target is an indirect graph, the content is n-quads,
# - triples are added to the document(default) graph.
# - quads are added to the document graph.
# - no statements are removed
# with a protocol target, the effect is as for put. the '/service' speicifes the default graph as target

curl -w "%{http_code}\n" -f -s -X PATCH \
     -H "Content-Type: application/n-quads" \
     --data-binary @- \
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}/service?default\&auth_token=${STORE_TOKEN} <<EOF \
   | grep_patch_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH1" <${STORE_NAMED_GRAPH}-two> .
EOF


curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | fgrep -v '"default object"' | fgrep '"named object"' | fgrep  "<${STORE_NAMED_GRAPH}>" \
   | fgrep '"default object PATCH1"' | fgrep '"named object PATCH1"' | fgrep  "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 3


curl -w "%{http_code}\n" -f -s -X PATCH \
     -H "Content-Type: application/n-quads" \
     --data-binary @- \
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}/service?default\&auth_token=${STORE_TOKEN} <<EOF \
  | grep_patch_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH2" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH2" <${STORE_NAMED_GRAPH}-two> .
EOF


curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | fgrep -v '"default object"' | fgrep '"named object"' | fgrep  "<${STORE_NAMED_GRAPH}>" \
   | fgrep -v '"default object PATCH1"' | fgrep '"named object PATCH1"' \
   | fgrep '"default object PATCH2"' | fgrep '"named object PATCH2"' | fgrep  "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 4

initialize_repository | grep_put_success
