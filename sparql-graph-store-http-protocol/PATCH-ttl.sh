#! /bin/bash

# the protocol target is the repository - as a direct graph, the content is turtle:
# - triples are added to the document (default) graph.
# - quads are added to the document graph.
# - statements are removed from the document graphs only
# with the repository as the target, the effect is a PUT on the individual document graphs.

curl -w "%{http_code}\n" -f -s -S -X PATCH \
     -H "Content-Type: application/turtle" \
     --data-binary @- \
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} <<EOF \
   | fgrep -q "${PATCH_SUCCESS}"
<http://example.com/default-subject>
    <http://example.com/default-predicate>
      "default object PATCH1" , 
      "named object PATCH1" <${STORE_NAMED_GRAPH}-two> .
EOF


curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | fgrep -v '"default object"' | fgrep '"named object"' | fgrep "<${STORE_NAMED_GRAPH}>" \
   | fgrep '"default object rdf-graphs PATCH1"' | fgrep '"named object rdf-graphs PATCH1"' | fgrep  "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 3


curl -w "%{http_code}\n" -f -s -S -X PATCH \
     -H "Content-Type: application/turtle" \
     --data-binary @- \
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} <<EOF \
   | fgrep -q "${PATCH_SUCCESS}"
<http://example.com/default-subject>
    <http://example.com/default-predicate>
      "default object PATCH1" , 
      "named object PATCH1" <${STORE_NAMED_GRAPH}-two> .
EOF


curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | fgrep -v '"default object"' | fgrep '"named object"' | fgrep "<${STORE_NAMED_GRAPH}>" \
   | fgrep -v '"default object rdf-graphs PATCH1"' | fgrep -v '"named object rdf-graphs PATCH1"' \
   | fgrep '"default object rdf-graphs PATCH2"' | fgrep '"named object rdf-graphs PATCH2"' | fgrep  "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 3


initialize_repository | fgrep -q "${PUT_SUCCESS}"
