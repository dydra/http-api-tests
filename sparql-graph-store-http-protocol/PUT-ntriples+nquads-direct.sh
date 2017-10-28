#! /bin/bash

# the protocol target is a direct graph, the statements include quads and the content type is n-triples or n-quads:
# - triples are added to the document (default) graph.
# - quads are added to the document graph.
# - statements are removed from the first put to the target graph.

initialize_repository --repository "${STORE_REPOSITORY}-write"

curl_graph_store_update -X PUT \
     -H "Content-Type: application/n-quads" \
    --repository "${STORE_REPOSITORY}-write" \
    --url "${STORE_NAMED_GRAPH_URL}" <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT1" <${STORE_NAMED_GRAPH}-two> .
EOF


curl_graph_store_update -X PUT \
     -H "Content-Type: application/n-triples" \
    --repository "${STORE_REPOSITORY}-write"\
    --url "${STORE_NAMED_GRAPH_URL}" <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT2" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT2" <${STORE_NAMED_GRAPH}-two> .
EOF


curl_graph_store_get \
     -H "Accept: application/n-quads" --repository "${STORE_REPOSITORY}-write" \
   | tr -s '\n' '\t' \
   | egrep '"default object"' | egrep '"named object"' | egrep  "<${STORE_NAMED_GRAPH}>" \
   | egrep -v "<${STORE_NAMED_GRAPH}-two>" | egrep -v "PUT1" \
   | egrep '"default object PUT2"' | egrep '"named object PUT2"' \
   | tr -s '\t' '\n' | egrep "${STORE_NAMED_GRAPH}-three" | wc -l | egrep -q 2
