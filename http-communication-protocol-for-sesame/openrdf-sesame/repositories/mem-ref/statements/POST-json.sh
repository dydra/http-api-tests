#! /bin/bash

# rdf json import
# - for the sesame protocol, even with a post request _no_ new graph is generated even though no graph is specified.


curl -w "%{http_code}\n" -f -s -X POST \
     -H "Content-Type: application/rdf+json" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?auth_token=${STORE_TOKEN} <<EOF \
   | egrep -q "${POST_SUCCESS}"
{ "http://example.com/default-subject" : {
  "http://example.com/default-predicate" : [ { "value" : "default object POST1",
                                               "type" : "literal" } ]
  }
}
EOF

curl -f -s -S -X GET \
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | fgrep '"default object"' | fgrep '"named object"' | fgrep  "default object POST1" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 3


curl -w "%{http_code}\n" -f -s -X POST \
     -H "Content-Type: application/rdf+json" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?auth_token=${STORE_TOKEN} <<EOF \
   | egrep -q "${POST_SUCCESS}"
{ "http://example.com/default-subject" : {
  "http://example.com/default-predicate" : [ { "value" : "default object POST2",
                                               "type" : "literal" } ]
  }
}
EOF


curl -f -s -S -X GET \
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | fgrep '"default object"' | fgrep '"named object"' | fgrep  "default object POST1" | fgrep  "default object POST2" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 4

initialize_repository | grep_put_success
