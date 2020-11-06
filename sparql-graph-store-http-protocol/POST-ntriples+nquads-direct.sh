#! /bin/bash

# the protocol target is a direct graph, the statements include quads and the content type is n-triples or n-quads:
# - triples are added to the protocol graph.
# - quads are added to the protocol graph.
# - no statements are removed

initialize_repository --repository "${STORE_REPOSITORY}-write"

# -o /tmp/gsp.ttl
curl_graph_store_update -X POST -o /dev/null \
     -H "Content-Type: application/n-quads" \
    --url "${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-write/graph-name" <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST1" <${STORE_NAMED_GRAPH}-one> .
EOF


# -o /tmp/gsp.ttl
curl_graph_store_update -X POST -o /dev/null \
     -H "Content-Type: application/n-triples" \
    --url "${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-write/graph-name" <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST2" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST2" <${STORE_NAMED_GRAPH}-two> .
EOF


curl_graph_store_get \
     -H "Accept: application/n-quads" --repository "${STORE_REPOSITORY}-write" \
   | tr -s '\n' '\t' \
   | fgrep '"default object"' | fgrep '"named object"' | fgrep  "<${STORE_NAMED_GRAPH}>" \
   | fgrep '"default object POST1"' | fgrep '"named object POST1"' \
   | fgrep '"default object POST2"' | fgrep '"named object POST2"' \
   | fgrep -v "<${STORE_NAMED_GRAPH}-two>" \
   | fgrep -v "<${STORE_NAMED_GRAPH}-one>" \
   | fgrep "${STORE_REPOSITORY}-write/graph-name>" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 6
