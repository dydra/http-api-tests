#! /bin/bash

# exercise the query parameters extension

curl_sparql_request '$parm=1' <<EOF | egrep -q '"value":.*"1"' 
select distinct ?p where { bind (?parm as ?p) }
EOF

