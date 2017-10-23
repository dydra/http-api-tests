#! /bin/bash

# verify write access for collaboration as jhacker access to the write repository

# first, add the collaboration access

curl_graph_store_update -X POST   -w "%{http_code}\n" \
     -H "Content-Type: application/n-quads" \
     --repository "system"  <<EOF \
   | test_post_success
_:collabaccess <http://www.w3.org/ns/auth/acl#mode> <http://www.w3.org/ns/auth/acl#Write> <http://dydra.com/openrdf-sesame/mem-rdf-write> .
_:collabaccess <http://www.w3.org/ns/auth/acl#mode> <http://www.w3.org/ns/auth/acl#Read> <http://dydra.com/openrdf-sesame/mem-rdf-write> .
_:collabaccess <http://www.w3.org/ns/auth/acl#accessTo> <http://dydra.com/openrdf-sesame/mem-rdf-write> <http://dydra.com/openrdf-sesame/mem-rdf-write> .
_:collabaccess <http://www.w3.org/ns/auth/acl#agent> <http://dydra.com/users/jhacker> <http://dydra.com/openrdf-sesame/mem-rdf-write> .
EOF

initialize_repository --repository "${STORE_REPOSITORY}-write"

# put content as jhacker
curl_graph_store_update -X PUT  -w "%{http_code}\n" \
     -H "Content-Type: application/n-triples" \
     --user "${STORE_TOKEN_JHACKER}:" \
     --repository "${STORE_REPOSITORY}-write" <<EOF  \
   | test_put_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT-triples-collab" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT-triples-collab" <${STORE_NAMED_GRAPH}-collab> .
EOF

curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
 | rapper -q -i nquads -o nquads /dev/stdin | sort | diff /dev/stdin /dev/fd/3 3<<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT-triples-collab" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT-triples-collab" <${STORE_NAMED_GRAPH}-collab> .
EOF
