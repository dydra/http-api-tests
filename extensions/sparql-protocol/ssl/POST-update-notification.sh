#! /bin/bash

# a test of update notification
# acts as a loopback by specifying the response body as the notification destination
#
# the request itself includes as arguments
#  query : the query text inline as sparql or an iri which designates the script by reference
#  script : either an inline script as turtle or an iri which designates the script by reference
#
# where the request is application/x-www-form-urlencoded the types of form elements is
# fixed by role. where multipart/form-data is used, each element can specify a content type.


curl_sparql_update \
     --repository "${STORE_REPOSITORY}-write" <<EOF \
   | jq '.boolean' | fgrep -q 'true'

INSERT DATA {
 GRAPH <http://example.org/uri1/${OBJECT_ID}> {
  <http://example.org/uri1/one> <foaf:name> "object-${OBJECT_ID}" .
  <http://example.org/uri1/one> rdf:type <http://example.org/thing> .
 }
}
EOF

curl_sparql_update "--data-urlencode" "query@/dev/fd/3" "script@/dev/fd/4" \
  -H "Content-Type: application/x-www-form-urlencoded" 3<<EOF3 4<<EOF4 \
 | jq '.results.bindings[] | .[].value' | fgrep -q "BSS84"
INSERT DATA {
 GRAPH <http://example.org/uri1/notification> {
  <http://example.org/uri1/one> <foaf:name> "object-for-notification" .
  <http://example.org/uri1/one> rdf:type <http://example.org/object-for-notification> .
 }
}
EOF3
[ a :Query ;
  :name 'Simple Query';
  :steps ( [ a :Decode; :location 'select * where {?s ?p ?o}'] 
           [ a :Bind ]
           [ a :Project ] 
           [ a :Encode ] 
           ) ] .")
EOF4
