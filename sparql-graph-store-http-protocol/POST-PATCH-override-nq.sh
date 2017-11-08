#! /bin/bash
# that the POST is overriden by the PATCH


initialize_repository --repository "${STORE_REPOSITORY}-write"

curl_graph_store_update -X POST   -w "%{http_code}\n" \
     -H "X-HTTP-Method-Override: PATCH" \
     -H "Content-Type: application/n-quads" \
     --repository "${STORE_REPOSITORY}-write"  <<EOF \
   | test_patch_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH-quads-none-one" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH-quads-one" <${STORE_NAMED_GRAPH}-one> .
EOF


curl_graph_store_update -X POST   -w "%{http_code}\n" \
     -H "X-HTTP-Method-Override: PATCH" \
     -H "Content-Type: application/n-quads" \
     --repository "${STORE_REPOSITORY}-write"  <<EOF \
   | test_patch_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH-quads-none-two" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH-quads-two" <${STORE_NAMED_GRAPH}-two> .
EOF


curl_graph_store_update -X PATCH   -w "%{http_code}\n" \
     -H "X-HTTP-Method-Override: PATCH" \
     -H "Content-Type: application/n-quads" \
     --repository "${STORE_REPOSITORY}-write"  <<EOF \
   | test_patch_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH-quads-none-three" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH-quads-two-again" <${STORE_NAMED_GRAPH}-two> .
EOF

curl_graph_store_get --repository "${STORE_REPOSITORY}-write" > POST-PATCH-out.nq
cat POST-PATCH-out.nq | fgrep -c "none-one" | fgrep -q "0"
cat POST-PATCH-out.nq | fgrep -c "none-two" | fgrep -q "0"
cat POST-PATCH-out.nq | fgrep -c "none-three" | fgrep -q "1"
cat POST-PATCH-out.nq | fgrep -c "quads-one" | fgrep -q "1"
cat POST-PATCH-out.nq | fgrep -c 'quads-two"' | fgrep -q "0"
cat POST-PATCH-out.nq | fgrep -c "quads-two-again" | fgrep -q "1"
cat POST-PATCH-out.nq | fgrep -c "graph-name>" | fgrep -q "1"

