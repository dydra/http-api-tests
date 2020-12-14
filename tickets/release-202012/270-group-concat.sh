#! /bin/bash
#
# test that a parsed value iri (from the filter) is identical with one where the parsed
# value has been stored and retrieved.
# the same test should apply to blank nodes, but there is no way to bind one

curl_sparql_request \
     -H "Accept: application/sparql-results+json" \
     -H "Content-Type:application/sparql-query" <<EOF \
 | tee $ECHO_OUTPUT | jq '.results.bindings[] | .[].value' | sort | diff - /dev/fd/2 2<<TEST
select ?state (group_concat(distinct ?value; separator='.') as ?result)
from <urn:dydra:all>
where {
  VALUES (?state ?prop) {
    ( 'one' 'p1' )
    ( 'one' 'p2' )
    ( 'two' 'p1' )
    ( 'two' 'p2' )
    ( 'two' 'p3' )
    ( 'three' 'p4')
  }        
  optional {
    VALUES (?prop ?value) {
      ( 'p1' 'first' )
      ( 'p2' 'second' )
    }
  }
}
group by ?state
EOF
""
"first.second"
"first.second"
"one"
"three"
"two"
TEST
