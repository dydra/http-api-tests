#! /bin/bash

# verify write access for user with read/write access

$CURL -w "%{http_code}\n" -f -s -S -X PUT \
     -H "Content-Type: application/n-quads" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-byuser?auth_token=${STORE_TOKEN}_READWRITE <<EOF \
  | egrep -q "$STATUS_PUT_SUCCESS"
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object PUT1" <${STORE_NAMED_GRAPH}-two> .
EOF


$CURL -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-byuser?auth_token=${STORE_TOKEN}_READWRITE \
   | tr -s '\n' '\t' \
   | egrep '"default object PUT1"' | egrep '"named object PUT1"' | egrep  "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | wc -l | egrep -q 2

# reset to minimal data
${CURL} -w "%{http_code}\n" -L -f -s -X PUT \
     -H "Accept: application/n-quads" \
     -H "Content-Type: application/n-quads" --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-byuser?auth_token=${STORE_TOKEN} <<EOF \
 | egrep -q "$STATUS_PUT_SUCCESS"
<http://example.com/subject> <http://example.com/predicate> "object" <${STORE_URL}>.
EOF
