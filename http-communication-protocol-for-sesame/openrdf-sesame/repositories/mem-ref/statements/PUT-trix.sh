#! /bin/bash


curl -w "%{http_code}\n" -f -s -X PUT \
     -H "Content-Type: application/trix" \
     --data-binary @- \
     $STORE_URL/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?auth_token=${STORE_TOKEN} <<EOF\
   | egrep -q "${PUT_SUCCESS}"
<?xml version="1.0" encoding="utf-8"?>
<TriX>
<graph>
  <triple>
   <uri>http://example.com/default-subject</uri>
   <uri>http://example.com/default-predicate</uri>
   <plainLiteral>default object . PUT.trix</plainLiteral>
  </triple>
</graph>
</TriX>
EOF

curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     $STORE_URL/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?auth_token=${STORE_TOKEN} \
   | fgrep -q 'PUT.trix'

initialize_repository | egrep -q "${POST_SUCCESS}"
