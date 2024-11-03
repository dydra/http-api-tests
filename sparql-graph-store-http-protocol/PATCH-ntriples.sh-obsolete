#! /bin/bash
set -o errexit

# the protocol target is the repository - as a direct graph, the statements include quads and the content type is n-triples:
# - triples are added to the document graph.
# - quads are added to the document graph.
# - statements are removed from the document graphs only
# with the repository as the target, the effect is a PUT on the default graph.

initialize_repository --repository "${STORE_REPOSITORY}-write"

curl_graph_store_update -X PATCH -o /dev/null \
     -H "Content-Type: application/n-triples" \
     --repository "${STORE_REPOSITORY}-write" \
     --data-binary @- <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH1" <${STORE_NAMED_GRAPH}-two> .
EOF


curl_graph_store_get \
     --repository "${STORE_REPOSITORY}-write"  \
   | tr -s '\n' '\t' \
   | fgrep -v '"default object"' | fgrep '"named object"' \
   | fgrep '"default object PATCH1"'| fgrep '"named object PATCH1"'| fgrep "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 3

