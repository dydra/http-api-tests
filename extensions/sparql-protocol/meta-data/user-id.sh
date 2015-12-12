#! /bin/bash

curl_sparql_request "user_id=test" <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q "\"test\""

PREFIX dydra: <http://dydra.com/sparql-functions#> 
SELECT ( dydra:user-tag() as ?result )
WHERE {}
EOF





