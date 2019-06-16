#! /bin/bash

# perform all put variations: default, graph=, none, (direct: nyi)
# verify intermediate deletions and additions
# verify the end result(s)


# put with no graph : clear the repository
# put triple content with no graph: store in the default graph. ignore any statement graph term (if permitted)
# put quad content with no graph: store in the statement graph, or default if triple statement
initialize_repository --repository "${STORE_REPOSITORY}-write"

echo "put triples w/ none"
# while, in theory, one coulr return a 400 and claim it is a protocol violatation, that leaves no
# easy way to clear a repositiry with named graph content and import just the default graph.
curl_graph_store_update -X PUT  -w "%{http_code}\n" -o /dev/null\
     -H "Content-Type: application/n-triples" \
     --repository "${STORE_REPOSITORY}-write"  <<EOF  \
   | test_put_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT-triples-none" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT-triples-none" <${STORE_NAMED_GRAPH}-two> .
EOF
curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
   | sort > PUT-out.nq
rapper -q -i nquads -o nquads PUT-out.nq > /dev/null
sort <<EOF > PUT-test.nq
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT-triples-none" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT-triples-none" <${STORE_NAMED_GRAPH}-two> .
EOF
diff -w PUT-out.nq PUT-test.nq

echo "put quads w/ none"
sort <<EOF > PUT-in.nq
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT-quads-none" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT-quads-none" <${STORE_NAMED_GRAPH}-two> .
EOF
curl_graph_store_update -X PUT   -w "%{http_code}\n" -o /dev/null \
     -H "Content-Type: application/n-quads" \
     --repository "${STORE_REPOSITORY}-write" < PUT-in.nq \
   | test_put_success
curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
   | sort > PUT-out.nq
rapper -q -i nquads -o nquads PUT-out.nq > /dev/null

diff -w PUT-out.nq PUT-in.nq

# put with default: clear the default graph
# put triple content with default: store in the default graph. ignore any statement graph term (if permitted)
# put quad content with default: store in the default graph. ignore any statement graph term
initialize_repository --repository "${STORE_REPOSITORY}-write"

# echo "put triples to default"
curl_graph_store_update -X PUT -o /dev/null \
     -H "Content-Type: application/n-triples" \
     --repository "${STORE_REPOSITORY}-write" default <<EOF 
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT-triples-default" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT-triples-default" <${STORE_NAMED_GRAPH}-two> .
EOF
curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
 | rapper -q -i nquads -o nquads /dev/stdin | sort | diff -w /dev/stdin /dev/fd/3 3<<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT-triples-default" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT-triples-default" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
EOF

# echo "put quads to default"
curl_graph_store_update -X PUT -o /dev/null \
     -H "Content-Type: application/n-quads" \
     --repository "${STORE_REPOSITORY}-write" default <<EOF 
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT-quads-default" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT-quads-default" <${STORE_NAMED_GRAPH}-two> .
EOF
curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
 | sort > PUT-out.nq
rapper -q -i nquads -o nquads PUT-out.nq > /dev/null
sort <<EOF > PUT-test.nq
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT-quads-default" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT-quads-default" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
EOF
diff -w PUT-out.nq PUT-test.nq

# put with graph: clear the target graph
# put triple content with graph: store in the target graph. ignore any graph term (if permitted)
# put quad content with graph: store in the target graph.
initialize_repository --repository "${STORE_REPOSITORY}-write"

# echo "put triples to graph"
curl_graph_store_update -X PUT -o /dev/null \
     -H "Content-Type: application/n-triples" \
     --repository "${STORE_REPOSITORY}-write" graph=${STORE_NAMED_GRAPH}-three <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT-triples-graph" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT-triples-graph" <${STORE_NAMED_GRAPH}-two> .
EOF
curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
 | sort > PUT-out.nq
rapper -q -i nquads -o nquads PUT-out.nq > /dev/null
sort <<EOF > PUT-test.nq
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT-triples-graph" <${STORE_NAMED_GRAPH}-three> .
<http://example.com/default-subject> <http://example.com/default-predicate> "default object" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT-triples-graph" <${STORE_NAMED_GRAPH}-three> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
EOF
diff -w PUT-out.nq PUT-test.nq

# echo "put quads to graph"
curl_graph_store_update -X PUT -o /dev/null \
     -H "Content-Type: application/n-quads" \
     --repository "${STORE_REPOSITORY}-write" graph=${STORE_NAMED_GRAPH}-three <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT-quads-graph" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT-quads-graph" <${STORE_NAMED_GRAPH}-two> .
EOF
curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
 | sort > PUT-out.nq
rapper -q -i nquads -o nquads PUT-out.nq > /dev/null
sort <<EOF > PUT-test.nq
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT-quads-graph" <${STORE_NAMED_GRAPH}-three> .
<http://example.com/default-subject> <http://example.com/default-predicate> "default object" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT-quads-graph" <${STORE_NAMED_GRAPH}-three> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
EOF
diff -w PUT-out.nq PUT-test.nq


# put direct: clear the target graph
# put triple content direct: store in the target graph. ignore any graph term (if permitted)
# put quad content direct: store in the target graph.
initialize_repository --repository "${STORE_REPOSITORY}-write"



# echo "put quads direct" NYI
#curl_graph_store_update -X PUT   -w "%{http_code}\n" -o /dev/null \
#     -H "Content-Type: application/n-quads" \
#    --url "${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-write/graph-name" <<EOF
#<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT-quads-direct" .
#<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT-quads-direct" <${STORE_NAMED_GRAPH}-two> .
#EOF
#curl_graph_store_get --repository "${STORE_REPOSITORY}-write" -o /dev/null \
# | rapper -q -i nquads -o nquads /dev/stdin | sort | diff -w /dev/stdin /dev/fd/3 3<<EOF
#<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT-quads-direct" <http://dydra.com/openrdf-sesame/mem-rdf/graph-name> .
#<http://example.com/default-subject> <http://example.com/default-predicate> "default object" .
#<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT-quads-direct" <http://dydra.com/openrdf-sesame/mem-rdf/graph-name> .
#EOF

rm PUT-test.nq
rm PUT-out.nq
rm PUT-in.nq

