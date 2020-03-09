#! /bin/bash

# the protocol target is a direct graph, the statements include quads and the content type is n-triples or n-quads:
# - triples are added to the document (default) graph.
# - quads are added to the document graph.
# - statements are removed from the first put to the target graph.

initialize_repository --repository "${STORE_REPOSITORY}-write"

curl_graph_store_update -X PUT -o /dev/null \
     -H "Content-Type: application/n-quads" \
    --url "${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-write/graph-name" <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT1" <${STORE_NAMED_GRAPH}-one> .
EOF


curl_graph_store_update -X PUT -o /dev/null \
     -H "Content-Type: application/n-triples" \
    --url "${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-write/graph-name" <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT2" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT2" <${STORE_NAMED_GRAPH}-two> .
EOF

# the first update is overwritten by the second
curl_graph_store_get \
     -H "Accept: application/n-quads" --repository "${STORE_REPOSITORY}-write" \
   | tr -s '\n' '\t' \
   | fgrep '"default object"' | fgrep '"named object"' | fgrep  "<${STORE_NAMED_GRAPH}>" \
   | fgrep -v '"default object PUT1"' | fgrep -v '"named object PUT1"' \
   | fgrep '"default object PUT2"' | fgrep '"named object PUT2"' \
   | fgrep -v "<${STORE_NAMED_GRAPH}-two>" \
   | fgrep -v "<${STORE_NAMED_GRAPH}-one>" \
   | fgrep "${STORE_REPOSITORY}-write/graph-name>" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 4
