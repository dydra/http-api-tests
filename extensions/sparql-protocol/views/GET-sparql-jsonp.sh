#! /bin/bash

# use an inline query to test just the jsonp encoding


curl_sparql_request -X POST -H "Accept: application/sparql-results+jsonp" > tmp.srjp <<EOF
select ?v
where {
  values ?v {
    false
    true
    'string'
    1
    # not permitted _:blank
    <http://www.w3.org/2001/XMLSchema#boolean>
  }
}
EOF

fgrep -q '{"type":"literal", "datatype":"http://www.w3.org/2001/XMLSchema#boolean", "value":"false"}' tmp.srjp
fgrep -q '{"type":"literal", "datatype":"http://www.w3.org/2001/XMLSchema#boolean", "value":"true"}' tmp.srjp
fgrep -q '{"type":"literal", "datatype":"http://www.w3.org/2001/XMLSchema#string", "value":"string"}' tmp.srjp
fgrep -q '{"type":"literal", "datatype":"http://www.w3.org/2001/XMLSchema#integer", "value":"1"}' tmp.srjp
fgrep -q '{"type":"uri", "value":"http://www.w3.org/2001/XMLSchema#boolean"}' tmp.srjp

