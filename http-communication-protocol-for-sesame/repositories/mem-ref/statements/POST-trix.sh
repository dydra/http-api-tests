#! /bin/bash


curl -w "%{http_code}\n" -f -s -X POST \
     -H "Content-Type: application/trix" \
     --data-binary @- \
     $STORE_URL/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/statements?auth_token=${STORE_TOKEN} <<EOF\
   | fgrep -q "${STATUS_UNSUPPORTED_MEDIA}"
<?xml version="1.0" encoding="utf-8"?>
<graph>
  <uri>http://dydra.com/put-graph-name</uri>
  <triple>
   <uri>http://example.com/default-subject</uri>
   <uri>http://example.com/default-predicate</uri>
   <plainLiteral>default object . PUT.nt</plainLiteral>
  </triple>
</graph>
EOF

initialize_repository | fgrep -q "${POST_SUCCESS}"

echo -n " NYI "
