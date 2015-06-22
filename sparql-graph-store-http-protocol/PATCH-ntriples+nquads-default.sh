#! /bin/bash

# the protocol target is the default graph, the statements include quads and the content type is n-triples:
# - triples are added to the protocol (default) graph.
# - quads are added to the protocol (default) graph.
# - statements are removed from the default graph
# with a protocol target, the effect is as for PUT.

initialize_repository --repository "${STORE_REPOSITORY}-write"

curl_graph_store_update -X PATCH \
     -H "Content-Type: application/n-triples" \
     --repository "${STORE_REPOSITORY}-write" default <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT1" <${STORE_NAMED_GRAPH}-two> .
EOF


curl_graph_store_update -X PATCH \
     -H "Content-Type: application/n-triples" \
     --repository "${STORE_REPOSITORY}-write" default <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT2" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT2" <${STORE_NAMED_GRAPH}-two> .
EOF

curl_graph_store_get \
     -H "Accept: application/n-quads" --repository "${STORE_REPOSITORY}-write" \
   | tr -s '\n' '\t' \
   | fgrep -v '"default object"' \
   | fgrep '"named object"' | fgrep  "<${STORE_NAMED_GRAPH}>" \
   | fgrep -v "PUT1" \
   | fgrep '"default object PUT2"'\
   | fgrep '"named object PUT2"'| fgrep "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 3
