#! /bin/bash


curl -w "%{http_code}\n" -f -s -X PUT \
     -H "Content-Type: application/rdf+json" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?auth_token=${STORE_TOKEN} <<EOF \
 | egrep -q "${PUT_SUCCESS}"
{ "http://example.com/default-subject" : {
  "http://example.com/default-predicate" : [ { "value" : "default object PUT1",
                                               "type" : "literal" } ]
  }
}
EOF

curl -f -s -S -X GET \
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | fgrep -v '"default object"' | fgrep -v '"named object"' | fgrep  "default object PUT1" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 1


curl -w "%{http_code}\n" -f -s -X PUT \
     -H "Content-Type: application/rdf+json" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?auth_token=${STORE_TOKEN} <<EOF \
   | egrep -q "${PUT_SUCCESS}"
{ "http://example.com/default-subject" : {
  "http://example.com/default-predicate" : [ { "value" : "default object PUT2",
                                               "type" : "literal" } ]
  }
}
EOF


curl -f -s -S -X GET \
     -H "Accept: application/n-quads" \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?auth_token=${STORE_TOKEN} \
   | tr -s '\n' '\t' \
   | fgrep -v '"default object"' | fgrep -v '"named object"' | fgrep -v "default object PUT1" | fgrep "default object PUT2" \
   | tr -s '\t' '\n' | wc -l | fgrep -q 1

initialize_repository | egrep -q "${PUT_SUCCESS}"
