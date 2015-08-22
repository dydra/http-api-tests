#! /bin/bash

# a test of simple query scripting
#
# the request itself includes as arguments
#  query :  a simple count
#  script : an inline script, as turtle, for a simple query

curl_sparql_query "--data-urlencode" "query1@/dev/fd/3" "script@/dev/fd/4" \
  -H "Content-Type: application/x-www-form-urlencoded" 3<<EOF3 4<<EOF4 \
 | jq '.results.bindings[] | .[].value' | fgrep -q "2"
"select (count(*) as ?count)"
EOF3
[ a :Query ;
  :name 'Simple Query';
  :steps ( [ a :Decode; :location _:query1] 
           [ a :Bind ]
           [ a :Project ] 
           [ a :Encode ] 
           ) ] .
EOF4
