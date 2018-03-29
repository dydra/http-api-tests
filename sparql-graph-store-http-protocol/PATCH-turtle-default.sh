#! /bin/bash

# the protocol target is the default graph, the content is turtle:
# - the default graph is cleared
# - triples are added to the document (default) graph.
# - quads are not present

initialize_repository --repository "${STORE_REPOSITORY}-write"

curl_graph_store_update -X PATCH -o /dev/null \
     -H "Content-Type: text/turtle" \
     --repository "${STORE_REPOSITORY}-write" default <<EOF
<http://example.com/default-subject>
    <http://example.com/default-predicate> "default object PATCH1" .
EOF


curl_graph_store_get \
     --repository "${STORE_REPOSITORY}-write"  \
   | tr -s '\n' '\t' \
   | fgrep -v '"default object"' | fgrep '"named object"' | fgrep "<${STORE_NAMED_GRAPH}>" \
   | fgrep '"default object PATCH1"' \
   | tr -s '\t' '\n' | wc -l | fgrep -q 2
