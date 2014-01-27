#! /bin/bash


$CURL -w "%{http_code}\n" -f -s -S -X PUT \
     -H "Content-Type: application/rdf+json" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} <<EOF\
 | egrep -q "$STATUS_PUT_SUCCESS"
{ "http://example.com/default-subject" : {
  "http://example.com/default-predicate" : [ { "value" : "default object PUT1",
                                               "type" : "literal" } ]
  },
  "http://example.com/named-subject" : {
  "http://example.com/named-predicate" : [ { "value" : "named object PUT1",
                                               "type" : "literal" } ]
  }
}
EOF


$CURL -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     $STORE_URL/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | fgrep '"default object PUT1"' | fgrep '"named object PUT1"' | fgrep -v "<${STORE_NAMED_GRAPH}-two>" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 2


initialize_repository | egrep -q "$STATUS_PUT_SUCCESS"
