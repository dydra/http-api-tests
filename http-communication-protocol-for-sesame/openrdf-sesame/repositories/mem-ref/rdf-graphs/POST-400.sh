#! /bin/bash

# an invalid content media type is either a bad request or unsupported

curl -w "%{http_code}\n" -f -s -X POST \
     -H "Content-Type: application/not-n-quads" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/rdf-graphs/sesame?auth_token=${STORE_TOKEN} <<EOF \
   | egrep -q "(${STATUS_BAD_REQUEST}|${STATUS_UNSUPPORTED_MEDIA})"
<http://example.com/default-subject> <http://example.com/default-predicate> "default object POST1" .
<http://example.com/named-subject> <http://example.com/named-predicate> "named object POST1" <${STORE_NAMED_GRAPH}-two> .
EOF
