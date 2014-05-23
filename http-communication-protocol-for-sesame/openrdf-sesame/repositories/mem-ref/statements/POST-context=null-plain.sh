#! /bin/bash

# test that a degenerate context argument is tolerated
# the effect is as if context=null were indicated, but do not test the graph disposition

curl -w "%{http_code}\n" -f -s -S -X POST \
     -H "Content-Type: application/n-quads" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?context\&auth_token=${STORE_TOKEN} <<EOF \
   | egrep -q "${POST_SUCCESS}"
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST1" <${STORE_NAMED_GRAPH}-two> .
EOF


curl -w "%{http_code}\n" -f -s -S -X POST \
     -H "Content-Type: application/n-triples" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?context=\&auth_token=${STORE_TOKEN} <<EOF \
   | egrep -q "${POST_SUCCESS}"
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST1" <${STORE_NAMED_GRAPH}-two> .
EOF

initialize_repository | egrep -q "${POST_SUCCESS}"
