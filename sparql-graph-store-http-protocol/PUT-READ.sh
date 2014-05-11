#! /bin/bash

# verify NO write access for user with read access only

$CURL -w "%{http_code}\n" -f -s -S -X PUT \
     -H "Content-Type: application/n-quads" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-byuser?auth_token=${STORE_TOKEN}_READ <<EOF \
  | fgrep -q "${STATUS_UNAUTHORIZED}"
<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT1" .
EOF

