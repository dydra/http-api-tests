#! /bin/bash

curl_sparql_request  \
     --repository "collation" <<EOF \
     | jq '.results.bindings[] | .value.value' | diff - ordered-values.txt 
select distinct ?value
where {
  ?s <http://example.org/value> ?value .
}
order by (?value)

EOF

