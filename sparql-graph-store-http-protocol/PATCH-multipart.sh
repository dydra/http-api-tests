#! /bin/bash

# perform all multipart patch
# verify the end result(s)

echo "multipart patch: initialize" > ${ECHO_OUTPUT}
initialize_repository --repository "${STORE_REPOSITORY}-write"

echo "add extra graph" > ${ECHO_OUTPUT}
curl_graph_store_update -X PATCH -o /dev/null \
     -H "Content-Type: multipart/related; boundary=patch" \
     --repository "${STORE_REPOSITORY}-write" <<EOF
--patch
X-HTTP-Method-Override: DELETE

<http://example.com/default-subject> <http://example.com/default-predicate> "default object" .
--patch
X-HTTP-Method-Override: POST

<http://example.com/default-subject> <http://example.com/default-predicate> "new object" .
--patch--
EOF


echo "test patch quads w/ none" > ${ECHO_OUTPUT}
curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
| rapper -q -i nquads -o nquads /dev/stdin | sort | diff -w /dev/stdin /dev/fd/3 3<<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "new object" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object" <http://dydra.com/openrdf-sesame/mem-rdf/graph-name> .
EOF



