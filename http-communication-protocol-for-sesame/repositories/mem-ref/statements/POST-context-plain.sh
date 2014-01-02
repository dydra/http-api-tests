#! /bin/bash

# test just that text/plain is allowed

curl -w "%{http_code}\n" -f -s -S -X POST \
     -H "Content-Type: text/plain" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?context=%3C${STORE_NAMED_GRAPH}-three%3E\&auth_token=${STORE_TOKEN} <<EOF \
   # | fgrep -q "${POST_SUCCESS}"
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST1" <${STORE_NAMED_GRAPH}-two> .
EOF


curl -f -s -S -X GET \
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | fgrep '"default object"' | fgrep '"named object"' | fgrep  "<${STORE_NAMED_GRAPH}>" \
   | fgrep -v "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | fgrep "${STORE_NAMED_GRAPH}-three" | wc -l | fgrep -q 2


initialize_repository | fgrep -q "${POST_SUCCESS}"
