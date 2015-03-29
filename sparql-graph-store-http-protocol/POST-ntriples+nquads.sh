#! /bin/bash
set -o errexit

# where no graph is provided and the statements include quads and the content type is n-triples or n-quads:
# - a new graph is generated as the encoding is n-triples and no graph is specified - thus the uuid urn
# - triples are added to the new graph.
# - quads are added to the new graph.
# - no statements are removed

initialize_repository --repository "${STORE_REPOSITORY}-write"

curl_graph_store_update -X POST \
     -H "Content-Type: application/n-triples"  \
     --repository "${STORE_REPOSITORY}-write" graph= <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST1" <${STORE_NAMED_GRAPH}-two> .
EOF


curl_graph_store_update -X POST \
     -H "Content-Type: application/n-quads"  \
     --repository "${STORE_REPOSITORY}-write" graph= <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST2" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST2" <${STORE_NAMED_GRAPH}-two> .
EOF


curl_graph_store_get \
     --repository "${STORE_REPOSITORY}-write"  \
   | tr -s '\n' '\t' \
   | egrep '"default object"' | egrep '"named object"' | egrep  "<${STORE_NAMED_GRAPH}>" \
   | egrep '"default object POST1"' | egrep '"named object POST1"' \
   | egrep '"default object POST2"' | egrep '"named object POST2"' | egrep  "urn:uuid" \
   | fgrep -v "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | wc -l | egrep -q 6

