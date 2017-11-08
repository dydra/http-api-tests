#! /bin/bash
# that the POST is overriden by the PATCH


initialize_repository --repository "${STORE_REPOSITORY}-write"

curl_graph_store_update -X POST   -w "%{http_code}\n" \
     -H "X-HTTP-Method-Override: PATCH" \
     -H "Content-Type: application/n-quads" \
     --repository "${STORE_REPOSITORY}-write"  <<EOF \
   | test_patch_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH-quads-none" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH-quads-none" <${STORE_NAMED_GRAPH}-one> .
EOF


curl_graph_store_update -X POST   -w "%{http_code}\n" \
     -H "X-HTTP-Method-Override: PATCH" \
     --repository "${STORE_REPOSITORY}-write"  <<EOF \
   | test_patch_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH-quads-none" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH-quads-two" <${STORE_NAMED_GRAPH}-two> .
EOF


curl_graph_store_update -X PATCH   -w "%{http_code}\n" \
     -H "Content-Type: application/n-quads" \
     --repository "${STORE_REPOSITORY}-write"  <<EOF \
   | test_patch_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH-quads-none" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH-quads-two-again" <${STORE_NAMED_GRAPH}-two> .
EOF

graph_store_get | fgrep -c "two-" | fgrep -s "1"
