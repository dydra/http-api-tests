#! /bin/bash

# perform all patch variations: default, graph=, none, (direct: nyi)
# verify intermediate deletions and additions
# verify the end result(s)


# patch with no graph : clear the repository
# patch triple content with no graph: store in the default graph. ignore any statement graph term (if permitted)
# patch quad content with no graph: store in the statement graph, or default if triple statement
initialize_repository --repository "${STORE_REPOSITORY}-write"

echo "add extra graph" > ${ECHO_OUTPUT}
curl_graph_store_update -X PUT -o /dev/null \
     -H "Content-Type: application/n-triples" \
     --repository "${STORE_REPOSITORY}-write" graph=${STORE_NAMED_GRAPH}-three <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "extra object PATCH-triples-extra-graph" .
EOF


echo "patch triples w/ none" > ${ECHO_OUTPUT}
curl_graph_store_update -X PATCH  -w "%{http_code}\n" -o /dev/null \
     -H "Content-Type: application/n-triples" \
     --repository "${STORE_REPOSITORY}-write"  <<EOF  \
   | test_bad_request
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH-triples-none" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH-triples-none" <${STORE_NAMED_GRAPH}-two> .
EOF

# the graph is now invalid for n-triples content
cat > /dev/null <<EOFEOF
echo "patch triples w/ none" > ${ECHO_OUTPUT}
curl_graph_store_update -X PATCH  -w "%{http_code}\n" -o /dev/null \
     -H "Content-Type: application/n-triples" \
     --repository "${STORE_REPOSITORY}-write"  <<EOF  \
   | test_patch_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH-triples-none" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH-triples-none" <${STORE_NAMED_GRAPH}-two> .
EOF

echo "test patch triples w/ none" > ${ECHO_OUTPUT}
curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
 | sort > PATCH-out.nq
rapper -q -i nquads -o nquads PATCH-out.nq > /dev/null 
sort <<EOF > PATCH-test.nq
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH-triples-none" .
<http://example.com/default-subject> <http://example.com/default-predicate> "extra object PATCH-triples-extra-graph" <${STORE_NAMED_GRAPH}-three> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH-triples-none" <${STORE_NAMED_GRAPH}-two> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
EOF
diff -w PATCH-out.nq PATCH-test.nq

# earlier known to fail, because patch triples w/ none should strip any statement graph. now it rejects the content
#<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH-triples-none" .
#<http://example.com/default-subject> <http://example.com/default-predicate> "extra object PATCH-triples-extra-graph" <${STORE_NAMED_GRAPH}-three> .
#<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH-triples-none" .
#<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
EOFEOF


echo "patch quads w/ none" > ${ECHO_OUTPUT}
curl_graph_store_update -X PATCH   -w "%{http_code}\n" -o /dev/null \
     -H "Content-Type: application/n-quads" \
     --repository "${STORE_REPOSITORY}-write"  <<EOF \
   | test_patch_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH-quads-none" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH-quads-none" <${STORE_NAMED_GRAPH}-two> .
EOF

echo "test patch quads w/ none" > ${ECHO_OUTPUT}
curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
 | sort > PATCH-out.nq
rapper -q -i nquads -o nquads PATCH-out.nq > /dev/null 
sort <<EOF > PATCH-test.nq
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH-quads-none" .
<http://example.com/default-subject> <http://example.com/default-predicate> "extra object PATCH-triples-extra-graph" <${STORE_NAMED_GRAPH}-three> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH-quads-none" <${STORE_NAMED_GRAPH}-two> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
EOF
diff -w PATCH-out.nq PATCH-test.nq

# patch with default: clear the default graph
# patch triple content with default: store in the default graph. ignore any statement graph term (if permitted)
# patch quad content with default: store in the default graph. ignore any statement graph term
initialize_repository --repository "${STORE_REPOSITORY}-write"

echo "add extra graph" > ${ECHO_OUTPUT}
curl_graph_store_update -X PUT -o /dev/null \
     -H "Content-Type: application/n-triples" \
     --repository "${STORE_REPOSITORY}-write" graph=${STORE_NAMED_GRAPH}-three <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "extra object PATCH-triples-extra-graph" .
EOF

# the graph is now invalid for n-triples content
cat > /dev/null <<EOFEOF
echo "patch triples to default" > ${ECHO_OUTPUT}
curl_graph_store_update -X PATCH -o /dev/null \
     -H "Content-Type: application/n-triples" \
     --repository "${STORE_REPOSITORY}-write" default <<EOF 
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH-triples-default" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH-triples-default" <${STORE_NAMED_GRAPH}-two> .
EOF

echo "test patch triples to default" > ${ECHO_OUTPUT}
curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
 | sort > PATCH-out.nq
rapper -q -i nquads -o nquads PATCH-out.nq > /dev/null 
sort <<EOF > PATCH-test.nq
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH-triples-default" .
<http://example.com/default-subject> <http://example.com/default-predicate> "extra object PATCH-triples-extra-graph" <${STORE_NAMED_GRAPH}-three> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH-triples-default" <${STORE_NAMED_GRAPH}-two> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
EOF
# known to fail. patch triples to default should replace any statement graph
#<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH-triples-default" .
#<http://example.com/default-subject> <http://example.com/default-predicate> "extra object PATCH-triples-extra-graph" <${STORE_NAMED_GRAPH}-three> .
#<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH-triples-default" .
#<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
EOFEOF

echo "patch quads to default" > ${ECHO_OUTPUT}
curl_graph_store_update -X PATCH -o /dev/null \
     -H "Content-Type: application/n-quads" \
     --repository "${STORE_REPOSITORY}-write" default <<EOF 
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH-quads-default" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH-quads-default" <${STORE_NAMED_GRAPH}-two> .
EOF
echo "test patch quads to default" > ${ECHO_OUTPUT}
curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
 | sort > PATCH-out.nq
rapper -q -i nquads -o nquads PATCH-out.nq > /dev/null 
if [ "${GRAPH_STORE_PATCH_LEGACY}" = "true" ]; then
# rdfcache/dydrad:
sort <<EOF > PATCH-test.nq
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH-quads-default" .
<http://example.com/default-subject> <http://example.com/default-predicate> "extra object PATCH-triples-extra-graph" <${STORE_NAMED_GRAPH}-three> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH-quads-default" <${STORE_NAMED_GRAPH}-two> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
EOF
else
# rlmdb:
sort <<EOF > PATCH-test.nq
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH-quads-default" .
<http://example.com/default-subject> <http://example.com/default-predicate> "extra object PATCH-triples-extra-graph" <${STORE_NAMED_GRAPH}-three> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH-quads-default" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
EOF
fi
diff -w PATCH-out.nq PATCH-test.nq
# known to fail. patch quads to default should replace any statement graph
#<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH-quads-default" .
#<http://example.com/default-subject> <http://example.com/default-predicate> "extra object PATCH-triples-extra-graph" <${STORE_NAMED_GRAPH}-three> .
#<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH-quads-default" .
#<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .


# patch with graph: clear the target graph
# patch triple content with graph: store in the target graph. ignore any graph term (if permitted)
# patch quad content with graph: store in the target graph.
initialize_repository --repository "${STORE_REPOSITORY}-write"

echo "add extra graph" > ${ECHO_OUTPUT}
curl_graph_store_update -X PUT -o /dev/null \
     -H "Content-Type: application/n-triples" \
     --repository "${STORE_REPOSITORY}-write" graph=${STORE_NAMED_GRAPH}-three <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "extra object PATCH-triples-extra-graph" .
EOF

# the graph is now invalid for n-triples content
cat > /dev/null <<EOFEOF
echo "patch triples to graph" > ${ECHO_OUTPUT}
curl_graph_store_update -X PATCH -o /dev/null \
     -H "Content-Type: application/n-triples" \
     --repository "${STORE_REPOSITORY}-write" graph=${STORE_NAMED_GRAPH}-three <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH-triples-graph" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH-triples-graph" <${STORE_NAMED_GRAPH}-two> .
EOF

echo "test patch triples to graph" > ${ECHO_OUTPUT}
curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
 | sort > PATCH-out.nq
rapper -q -i nquads -o nquads PATCH-out.nq > /dev/null 
if [ "${GRAPH_STORE_PATCH_LEGACY}" = "true" ]; then
# rdfcache/dydrad:
sort <<EOF > PATCH-test.nq
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH-triples-graph" .
<http://example.com/default-subject> <http://example.com/default-predicate> "extra object PATCH-triples-extra-graph" <${STORE_NAMED_GRAPH}-three> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH-triples-graph" <${STORE_NAMED_GRAPH}-two> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
EOF
else
# rlmdb:
sort <<EOF > PATCH-test.nq
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH-triples-graph" <${STORE_NAMED_GRAPH}-three> .
<http://example.com/default-subject> <http://example.com/default-predicate> "default object" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH-triples-graph" <${STORE_NAMED_GRAPH}-three> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
EOF
fi
diff -w PATCH-out.nq PATCH-test.nq
# known to fail. patch triples to graph should replace any statement graph
#<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH-triples-graph" <${STORE_NAMED_GRAPH}-three> .
#<http://example.com/default-subject> <http://example.com/default-predicate> "default object" .
#<http://example.com/default-subject> <http://example.com/default-predicate> "extra object PATCH-triples-extra-graph" <${STORE_NAMED_GRAPH}-three> .
#<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH-triples-graph" <${STORE_NAMED_GRAPH}-two> .
#<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
EOFEOF

echo "patch quads to graph" > ${ECHO_OUTPUT}
curl_graph_store_update -X PATCH -o /dev/null \
     -H "Content-Type: application/n-quads" \
     --repository "${STORE_REPOSITORY}-write" graph=${STORE_NAMED_GRAPH}-three <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH-quads-graph" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH-quads-graph" <${STORE_NAMED_GRAPH}-two> .
EOF

echo "test patch quads to graph" > ${ECHO_OUTPUT}
curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
 | sort > PATCH-out.nq
rapper -q -i nquads -o nquads PATCH-out.nq > /dev/null 
if [ "${GRAPH_STORE_PATCH_LEGACY}" = "true" ]; then
# rdfcache/dydrad:
sort <<EOF > PATCH-test.nq
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH-quads-graph" .
<http://example.com/default-subject> <http://example.com/default-predicate> "extra object PATCH-triples-extra-graph" <${STORE_NAMED_GRAPH}-three> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH-quads-graph" <${STORE_NAMED_GRAPH}-two> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
EOF
else
# rlmdb:
sort <<EOF > PATCH-test.nq
<http://example.com/default-subject> <http://example.com/default-predicate> "default object" .
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH-quads-graph" <${STORE_NAMED_GRAPH}-three> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH-quads-graph" <${STORE_NAMED_GRAPH}-three> .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
EOF
fi
diff -w PATCH-out.nq PATCH-test.nq
# known to fail : patch quads to graph should replace any statement graph
#<http://example.com/default-subject> <http://example.com/default-predicate> "default object PATCH-quads-graph" <${STORE_NAMED_GRAPH}-three> .
#<http://example.com/default-subject> <http://example.com/default-predicate> "default object" .
#<http://example.com/default-subject> <http://example.com/default-predicate> "extra object PATCH-triples-extra-graph" <${STORE_NAMED_GRAPH}-three> .
#<http://example.com/named-subject> <http://example.com/named-predicate> "named object PATCH-quads-graph" <${STORE_NAMED_GRAPH}-three> .
#<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <${STORE_NAMED_GRAPH}> .
