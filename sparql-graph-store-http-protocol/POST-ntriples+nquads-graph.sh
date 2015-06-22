#! /bin/bash

# the protocol target is an indirect graph, the statements include quads and the content type is n-triples or n-quads:
# - triples are added to the protocol graph.
# - quads are added to the protocol graph.
# - statements are retained the second time in the protocol graph

initialize_repository --repository "${STORE_REPOSITORY}-write"

curl_graph_store_update -X POST \
     -H "Content-Type: application/n-triples"  \
     --repository "${STORE_REPOSITORY}-write" \
     graph=${STORE_NAMED_GRAPH}-three <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST1" <${STORE_NAMED_GRAPH}-two> .
EOF


curl_graph_store_update -X POST \
     -H "Content-Type: application/n-quads"  \
     --repository "${STORE_REPOSITORY}-write" \
     graph=${STORE_NAMED_GRAPH}-three <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST2" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST2" <${STORE_NAMED_GRAPH}-two> .
EOF


curl_graph_store_get \
     --repository "${STORE_REPOSITORY}-write" \
   | tr -s '\n' '\t' \
   | egrep '"default object"' | egrep '"named object"' | egrep  "<${STORE_NAMED_GRAPH}>" \
   | egrep -v "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | egrep "${STORE_NAMED_GRAPH}-three" | wc -l | egrep -q 4
