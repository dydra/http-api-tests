#! /bin/bash

curl_sparql_request  \
     --repository "collation" <<EOF \
     | jq '.results.bindings[] | .value.value' | diff - ordered-values.txt 
select distinct (floor(?v) as ?value)
where {
  ?s <http://example.org/value> ?v .
}
order by (?value)

EOF

