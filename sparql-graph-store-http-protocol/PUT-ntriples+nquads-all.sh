#! /bin/bash
set -o errexit

# where the protocol target is the repository, the statements include quads and the content type is n-triples or n-quads:
# - the repository is cleared
# - triples are added to the document(default) graph.
# - quads are added to the document graph.

initialize_repository --repository "${STORE_REPOSITORY}-write"

curl_graph_store_update -X PUT \
     -H "Content-Type: application/n-quads"  \
     --repository "${STORE_REPOSITORY}-write" all <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT1" <${STORE_NAMED_GRAPH}-two> .
EOF


curl_graph_store_update -X PUT \
     -H "Content-Type: application/n-quads"  \
     --repository "${STORE_REPOSITORY}-write" all <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT2" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT2" <${STORE_NAMED_GRAPH}-two> .
EOF


curl_graph_store_get \
     --repository "${STORE_REPOSITORY}-write" \
   | tr -s '\n' '\t' \
   | fgrep -v '"default object"' | fgrep -v '"named object"' | fgrep -v "<${STORE_NAMED_GRAPH}>" \
   | fgrep -v '"default object PUT1"' | fgrep -v '"named object PUT1"' \
   | fgrep '"default object PUT2"' | fgrep '"named object PUT2"' \
   | fgrep  "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 2


