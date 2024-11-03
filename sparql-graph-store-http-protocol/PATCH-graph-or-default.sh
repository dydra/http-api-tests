#! /bin/bash
set -o errexit

# the protocol target is an indirect target graph, the content is n-triples and n-quads:
# - the target graph is cleared
#   - with n-quads media, triples and quads are added to the protocol graph
#   - with n-triples media, identified resources are first removed from the target graph, then content is inserted
# - with no target graph
#   - with n-quads media, content is replaced in each graph present in the document
#   - with n-triples, identified resources are replaced in the default graph
#

# initial repository content
# <http://example.com/named-subject> <http://example.com/named-predicate> "named object" <http://dydra.com/openrdf-sesame/mem-rdf/graph-name> .
# <http://example.com/default-subject> <http://example.com/default-predicate> "default object" .

echo "verify rejection of mismatched content and media type"  > $ECHO_OUTPUT
curl_graph_store_update -X PATCH -w "%{http_code}\n" -o /dev/null \
     -H "Content-Type: application/n-triples" \
     --repository "${STORE_REPOSITORY}-write" graph=${STORE_NAMED_GRAPH}-three \
     --data-binary @- <<EOF \
  | test_bad_request
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH1" <${STORE_NAMED_GRAPH}-two> .
EOF


#ok
echo "test with target graph, n-triples content replaces the identified resources in the target graph"  > $ECHO_OUTPUT
initialize_repository --repository "${STORE_REPOSITORY}-write"

curl_graph_store_update -X PATCH -o /dev/null \
     -H "Content-Type: application/n-triples" \
     --repository "${STORE_REPOSITORY}-write" graph=${STORE_NAMED_GRAPH}-three \
     --data-binary @- <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH1" .
EOF

curl_graph_store_update -X PATCH -w "%{http_code}\n" -o /dev/null \
     -H "Content-Type: application/n-quads" \
     --repository "${STORE_REPOSITORY}-write" graph=${STORE_NAMED_GRAPH}-three \
     --data-binary @- <<EOF \
  | test_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object" .
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH1" <http://dydra.com/test/test/graph-name-three> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <http://dydra.com/test/test/graph-name> .
EOF

initialize_repository --repository "${STORE_REPOSITORY}-write"

# accepted as alternative expression to target the default graph
curl_graph_store_update -X PATCH -o /dev/null \
     -H "Content-Type: application/n-triples" \
     --repository "${STORE_REPOSITORY}-write" graph=default \
     --data-binary @- <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH1" .
EOF

curl_graph_store_update -X PATCH -w "%{http_code}\n" -o /dev/null \
     -H "Content-Type: application/n-quads" \
     --repository "${STORE_REPOSITORY}-write" graph=${STORE_NAMED_GRAPH}-three \
     --data-binary @- <<EOF \
  | test_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <http://dydra.com/test/test/graph-name> .
EOF


echo "test with target graph, n-quads content all replaces respective content graph and the protocol graph is ignored"  > $ECHO_OUTPUT
initialize_repository --repository "${STORE_REPOSITORY}-write"

curl_graph_store_update -X PATCH -w "%{http_code}\n" -o /dev/null \
     -H "Content-Type: application/n-quads" \
     --repository "${STORE_REPOSITORY}-write" graph=${STORE_NAMED_GRAPH}-three \
     --data-binary @- <<EOF \
  | test_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH1" <${STORE_NAMED_GRAPH}-two> .
EOF

curl_graph_store_get \
     --repository "${STORE_REPOSITORY}-write"  \
   | sort | tee ${ECHO_OUTPUT} \
   | diff - /dev/fd/3 3<<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH1" <http://dydra.com/test/test/graph-name-two> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <http://dydra.com/test/test/graph-name> .
EOF


#ok
echo "test without a graph, n-triples content replaces the identified  resources in the default graph"  > $ECHO_OUTPUT
initialize_repository --repository "${STORE_REPOSITORY}-write"

curl_graph_store_update -X PATCH -w "%{http_code}\n" -o /dev/null \
     -H "Content-Type: application/n-triples" \
     --repository "${STORE_REPOSITORY}-write" \
     --data-binary @- <<EOF \
  | test_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH1" .
<http://example.com/new-subject> <http://example.com/default-predicate> "default object PATCH1" .
EOF

curl_graph_store_get \
     --repository "${STORE_REPOSITORY}-write"  \
   | sort | tee ${ECHO_OUTPUT} \
   | diff - /dev/fd/3 3<<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <http://dydra.com/test/test/graph-name> .
<http://example.com/new-subject> <http://example.com/default-predicate> "default object PATCH1" .
EOF


#ok
echo "test without a graph, n-quads content all replaces the respective graphs"  > $ECHO_OUTPUT
initialize_repository --repository "${STORE_REPOSITORY}-write"

curl_graph_store_update -X PATCH -w "%{http_code}\n" -o /dev/null \
     -H "Content-Type: application/n-quads" \
     --repository "${STORE_REPOSITORY}-write" \
     --data-binary @- <<EOF \
  | test_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH1" <${STORE_NAMED_GRAPH}-two> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH1" <${STORE_NAMED_GRAPH}-three> .
EOF

curl_graph_store_get \
     --repository "${STORE_REPOSITORY}-write"  \
   | sort | tee ${ECHO_OUTPUT} \
   | diff - /dev/fd/3 3<<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH1" <http://dydra.com/test/test/graph-name-three> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH1" <http://dydra.com/test/test/graph-name-two> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <http://dydra.com/test/test/graph-name> .
EOF

