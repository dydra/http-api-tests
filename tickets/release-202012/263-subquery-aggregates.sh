#! /bin/bash
#
# a subselect should combine with other fields even if it projects solutions which are dimensioned
# in non-alphabetical order.
# this is necessary where one binding depends on predecessors

curl_sparql_request \
     -H "Accept: application/sparql-results+json" \
     -H "Content-Type:application/sparql-query" <<EOF \
 | tee $ECHO_OUTPUT | fgrep -c '"o"' | fgrep -q 3
select *
from <urn:dydra:all>
where {
  {
    select ?s (sample(?o) as ?o_sample) {
      ?s ?p ?o
    }
    group by ?s
  }
  ?s ?p ?o .
}
EOF
