#! /bin/bash

# perform all post variations: default, graph=, none, (direct: nyi)
# verify the end result

# post with no graph :
# - start from default initial content
# - post triple content with no graph: should store in the generated uuid graph and ignore any statement graph term
# - post quad content with no graph: should store in the statement graph, or default if triple statement
# the latter should not generate a new graph and the former should succeed according to configuration

echo initialize repository > $ECHO_OUTPUT
initialize_repository --repository "${STORE_REPOSITORY}-write"

echo "post triples, no graph" > $ECHO_OUTPUT
curl_graph_store_update -X POST  -w "%{http_code}\n" -o /dev/null \
     -H "Content-Type: application/n-triples" \
     --repository "${STORE_REPOSITORY}-write"  <<EOF  \
   | test_post_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST-triples-none" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST-triples-none" <${STORE_NAMED_GRAPH}-two> .
EOF
echo "post quads, no graph"  > $ECHO_OUTPUT
# this will fail if the quad graph is replaced with a new UUID
curl_graph_store_update -X POST -w "%{http_code}\n" -o /dev/null \
     -H "Content-Type: application/n-quads" \
     --repository "${STORE_REPOSITORY}-write"  <<EOF \
   | test_post_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST-quads-none" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST-quads-none" <${STORE_NAMED_GRAPH}-two> .
EOF
# test that the initial content is present, that the triple content graph is an uuid value and that the quad request graph is retained
echo "test no graph content" > $ECHO_OUTPUT
curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
 | sort > POST-out.nq
rapper -q -i nquads -o nquads POST-out.nq > /dev/null
fgrep -c -i uuid POST-out.nq | fgrep -q 2
sort <<EOF > POST-test.nq
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST-quads-none" .
<http://example.com/default-subject> <http://example.com/default-predicate> "default object" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST-quads-none" <${STORE_NAMED_GRAPH}-two> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
EOF
fgrep -v -i uuid POST-out.nq | diff -w POST-test.nq /dev/stdin

# post triples to default
# - start from default initial content
# - post triple content with default: should store in the default graph. ignore any statement graph term (if permitted)
# - post quad content with default: should store in the default graph. ignore any statement graph term
initialize_repository --repository "${STORE_REPOSITORY}-write"

echo "post triples to default" > $ECHO_OUTPUT
curl_graph_store_update -X POST -o /dev/null \
     -H "Content-Type: application/n-triples" \
     --repository "${STORE_REPOSITORY}-write" default <<EOF 
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST-triples-default" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST-triples-default" <${STORE_NAMED_GRAPH}-two> .
EOF
echo "post quads to default" > $ECHO_OUTPUT
curl_graph_store_update -X POST -o /dev/null \
     -H "Content-Type: application/n-quads" \
     --repository "${STORE_REPOSITORY}-write" default <<EOF 
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST-quads-default" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST-quads-default" <${STORE_NAMED_GRAPH}-two> .
EOF
echo "test default content" > $ECHO_OUTPUT
curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
 | sort > POST-out.nq
rapper -q -i nquads -o nquads  POST-out.nq > /dev/null 
sort <<EOF > POST-test.nq
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST-quads-default" .
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST-triples-default" .
<http://example.com/default-subject> <http://example.com/default-predicate> "default object" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST-quads-default" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST-triples-default" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
EOF
diff -w POST-out.nq POST-test.nq

# post with graph:
# - start from default initial content
# - post triple content with graph: should store in the target graph. ignore any graph term (if permitted)
# - post quad content with graph: should store in the target graph.
initialize_repository --repository "${STORE_REPOSITORY}-write"

echo "post triples to graph" > $ECHO_OUTPUT
curl_graph_store_update -X POST -o /dev/null \
     -H "Content-Type: application/n-triples" \
     --repository "${STORE_REPOSITORY}-write" graph=${STORE_NAMED_GRAPH}-three <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST-triples-graph" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST-triples-graph" <${STORE_NAMED_GRAPH}-two> .
EOF
echo "post quads to graph" > $ECHO_OUTPUT
curl_graph_store_update -X POST -o /dev/null \
     -H "Content-Type: application/n-quads" \
     --repository "${STORE_REPOSITORY}-write" graph=${STORE_NAMED_GRAPH}-three <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST-quads-graph" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST-quads-graph" <${STORE_NAMED_GRAPH}-two> .
EOF
echo "test graph content" > $ECHO_OUTPUT
curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
 | sort > POST-out.nq
rapper -q -i nquads -o nquads POST-out.nq > /dev/null 
sort <<EOF > POST-test.nq
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST-quads-graph" <${STORE_NAMED_GRAPH}-three> .
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST-triples-graph" <${STORE_NAMED_GRAPH}-three> .
<http://example.com/default-subject> <http://example.com/default-predicate> "default object" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST-quads-graph" <${STORE_NAMED_GRAPH}-three> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST-triples-graph" <${STORE_NAMED_GRAPH}-three> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
EOF

diff -w POST-out.nq POST-test.nq

rm POST-test.nq




