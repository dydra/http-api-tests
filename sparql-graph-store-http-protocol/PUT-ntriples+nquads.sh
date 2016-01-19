#! /bin/bash

# the request includes no graph, which means the protocol target coincides with the repository, 
# if the content type is n-quads:
# - each operation first clears the repository
# - triples are added to the default graph.
# - quads are added to the document graph.
# otherwise it fails

initialize_repository --repository "${STORE_REPOSITORY}-write"


curl_graph_store_update -X PUT  -w "%{http_code}\n" \
     -H "Content-Type: application/n-triples" \
     --repository "${STORE_REPOSITORY}-write"  <<EOF  \
   | test_put_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT1" <${STORE_NAMED_GRAPH}-two> .
EOF


curl_graph_store_update -X PUT   -w "%{http_code}\n" \
     -H "Content-Type: application/n-quads" \
     --repository "${STORE_REPOSITORY}-write"  <<EOF \
   | test_put_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT2" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT2" <${STORE_NAMED_GRAPH}-two> .
EOF

curl_graph_store_get \
     -H "Accept: application/n-quads" --repository "${STORE_REPOSITORY}-write" \
   | tr -s '\n' '\t' \
   | fgrep -v '"default object"' | fgrep -v '"named object"' \
   | fgrep -v '"default object PUT1"' | fgrep -v '"named object PUT1"' \
   | fgrep '"default object PUT2"' | fgrep '"named object PUT2"' | fgrep "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 2
