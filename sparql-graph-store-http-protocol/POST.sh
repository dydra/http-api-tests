#! /bin/bash

# perform all post variations: default, graph=, none, (direct: nyi)
# verify the end result


# post with no graph : do not clear the repository; potentially generate a new uuid target graph
# post triple content with no graph : store in the uuid graph. ignore any statement graph term (if permitted)
# post quad content with no graph: store in the statement graph, or default if triple statement (not the uuid graph)
initialize_repository --repository "${STORE_REPOSITORY}-write"

# echo "post triples w/ none"
curl_graph_store_update -X POST  -w "%{http_code}\n" \
     -H "Content-Type: application/n-triples" \
     --repository "${STORE_REPOSITORY}-write"  <<EOF  \
   | test_post_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST-triples-none" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST-triples-none" <${STORE_NAMED_GRAPH}-two> .
EOF
# echo "post quads w/ none"
curl_graph_store_update -X POST   -w "%{http_code}\n" \
     -H "Content-Type: application/n-quads" \
     --repository "${STORE_REPOSITORY}-write"  <<EOF \
   | test_post_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST-quads-none" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST-quads-none" <${STORE_NAMED_GRAPH}-two> .
EOF
curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
 | rapper -q -i nquads -o nquads /dev/stdin | sort > POST-out.nq
fgrep -c -i uuid POST-out.nq | fgrep -q 2
fgrep -v -i uuid POST-out.nq | diff /dev/stdin /dev/fd/3 3<<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST-quads-none" .
<http://example.com/default-subject> <http://example.com/default-predicate> "default object" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST-quads-none" <${STORE_NAMED_GRAPH}-two> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
EOF

# post with default: do not clear the default graph
# post triple content with default: store in the default graph. ignore any statement graph term (if permitted)
# post quad content with default: store in the default graph. ignore any statement graph term
initialize_repository --repository "${STORE_REPOSITORY}-write"

# echo "post triples to default"
curl_graph_store_update -X POST \
     -H "Content-Type: application/n-triples" \
     --repository "${STORE_REPOSITORY}-write" default <<EOF 
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST-triples-default" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST-triples-default" <${STORE_NAMED_GRAPH}-two> .
EOF
# echo "post quads to default"
curl_graph_store_update -X POST \
     -H "Content-Type: application/n-quads" \
     --repository "${STORE_REPOSITORY}-write" default <<EOF 
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST-quads-default" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST-quads-default" <${STORE_NAMED_GRAPH}-two> .
EOF
curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
 | rapper -q -i nquads -o nquads /dev/stdin | sort | diff /dev/stdin /dev/fd/3 3<<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST-quads-default" .
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST-triples-default" .
<http://example.com/default-subject> <http://example.com/default-predicate> "default object" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST-quads-default" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST-triples-default" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
EOF

# post with graph: do notclear the target graph
# post triple content with graph: store in the target graph. ignore any graph term (if permitted)
# post quad content with graph: store in the target graph.
initialize_repository --repository "${STORE_REPOSITORY}-write"

# echo "post triples to graph"
curl_graph_store_update -X POST \
     -H "Content-Type: application/n-triples" \
     --repository "${STORE_REPOSITORY}-write" graph=${STORE_NAMED_GRAPH}-three <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST-triples-graph" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST-triples-graph" <${STORE_NAMED_GRAPH}-two> .
EOF
# echo "post quads to graph"
curl_graph_store_update -X POST \
     -H "Content-Type: application/n-quads" \
     --repository "${STORE_REPOSITORY}-write" graph=${STORE_NAMED_GRAPH}-three <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST-quads-graph" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST-quads-graph" <${STORE_NAMED_GRAPH}-two> .
EOF
curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
 | rapper -q -i nquads -o nquads /dev/stdin | sort | diff /dev/stdin /dev/fd/3 3<<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST-quads-graph" <${STORE_NAMED_GRAPH}-three> .
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST-triples-graph" <${STORE_NAMED_GRAPH}-three> .
<http://example.com/default-subject> <http://example.com/default-predicate> "default object" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST-quads-graph" <${STORE_NAMED_GRAPH}-three> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST-triples-graph" <${STORE_NAMED_GRAPH}-three> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
EOF



