#! /bin/bash

# the protocol target is the repository - as a direct graph, the statements include quads and the content type is n-triples:
# - triples are added to the document (default) graph.
# - quads are added to the document graph.
# - statements are removed from the document graphs only
# with the repository as the target, the effect is a PUT on the default graph.

curl -w "%{http_code}\n" -f -s -S -X PATCH \
     -H "Content-Type: application/n-triples" \
     --data-binary @- \
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}?graph=${STORE_NAMED_GRAPH}-three\&auth_token=${STORE_TOKEN} <<EOF \
  | grep_patch_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH1" <${STORE_NAMED_GRAPH}-two> .
EOF


curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | fgrep -v '"default object"' | fgrep '"named object"' | fgrep  "<${STORE_NAMED_GRAPH}>" \
   | fgrep '"default object PATCH1"'| fgrep '"named object PATCH1"'| fgrep -v "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 3


curl -w "%{http_code}\n" -f -s -S -X PATCH \
     -H "Content-Type: application/n-triples" \
     --data-binary @- \
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}?graph=${STORE_NAMED_GRAPH}-three\&auth_token=${STORE_TOKEN} <<EOF \
  | grep_patch_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH2" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH2" <${STORE_NAMED_GRAPH}-two> .
EOF


curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | fgrep '"default object"' | fgrep '"named object"' | fgrep  "<${STORE_NAMED_GRAPH}>" \
   | fgrep -v 'PATCH1'  | fgrep '"default object PATCH2"' | fgrep '"named object PATCH2"'| fgrep -v "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | fgrep "${STORE_NAMED_GRAPH}-three" | wc -l | fgrep -q 3


initialize_repository | grep_put_success
