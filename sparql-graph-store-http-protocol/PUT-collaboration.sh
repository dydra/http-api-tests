#! /bin/bash

# verify write access for collaboration as collaborator access to the write repository


echo "first, add the collaboration access" > $ECHO_OUTPUT
curl_graph_store_update -X POST   -w "%{http_code}\n" -o /dev/null \
     -H "Content-Type: application/n-quads" \
     --repository "system"  <<EOF \
   | test_post_success
_:collabaccess <http://www.w3.org/ns/auth/acl#mode> <http://www.w3.org/ns/auth/acl#Write> <http://dydra.com/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY_WRITABLE}> .
_:collabaccess <http://www.w3.org/ns/auth/acl#mode> <http://www.w3.org/ns/auth/acl#Read> <http://dydra.com/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY_WRITABLE}> .
_:collabaccess <http://www.w3.org/ns/auth/acl#accessTo> <http://dydra.com/openrdf-sesame/mem-rdf-write> <http://dydra.com/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY_WRITABLE}> .
_:collabaccess <http://www.w3.org/ns/auth/acl#accessTo> <http://dydra.com/account/openrdf-sesame/repository/mem-rdf-write> <http://dydra.com/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY_WRITABLE}> .
_:collabaccess <http://www.w3.org/ns/auth/acl#agent> <http://dydra.com/users/jhacker> <http://dydra.com/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY_WRITABLE}> .
EOF

initialize_repository --repository "${STORE_REPOSITORY_WRITABLE}"

echo "put content as jhacker" > $ECHO_OUTPUT
curl_graph_store_update -X PUT  -w "%{http_code}\n" -o /dev/null \
     -H "Content-Type: application/n-triples" \
     -u ":${STORE_TOKEN_COLLABORATOR}" \
     --repository "${STORE_REPOSITORY_WRITABLE}" <<EOF  \
   | test_put_success
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT-triples-collab" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT-triples-collab" <${STORE_NAMED_GRAPH}-collab> .
EOF

echo ")test content" > $ECHO_OUTPUT
curl_graph_store_get --repository "${STORE_REPOSITORY_WRITABLE}" \
 | rapper -q -i nquads -o nquads /dev/stdin | sort | diff /dev/stdin /dev/fd/3 3<<EOF
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT-triples-collab" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT-triples-collab" <${STORE_NAMED_GRAPH}-collab> .
EOF
