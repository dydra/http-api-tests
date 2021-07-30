#! /bin/bash
#
# test that the exists operator is compiled in the correct field context.
# with the context, the expected statement pattern variables are bound.
# absent the constraint, the match succeeds

curl_sparql_request \
     -H "Accept: application/sparql-results+json" \
     -H "Content-Type:application/sparql-query" <<EOF \
 | json_reformat -m \
 | tee $ECHO_OUTPUT \
 | egrep -q -s '"bindings".*"named".*"value":"false"'
select ?subject ?named
from <urn:dydra:all>
where {
  ?subject <http://example.com/default-predicate> ?object1
  BIND (EXISTS { ?subject <http://example.com/named-predicate> ?object2 } as ?named)
}
EOF

curl_sparql_request \
     -H "Accept: application/sparql-results+json" \
     -H "Content-Type:application/sparql-query" <<EOF \
 | tee $ECHO_OUTPUT \
 | json_reformat -m \
 | egrep -q -s '"bindings".*"named".*"value":"true"'
select ?subject ?named
from <urn:dydra:all>
where {
  ?subject <http://example.com/default-predicate> ?object1
  BIND (EXISTS { ?subject2 <http://example.com/named-predicate> ?object2 } as ?named)
}
EOF
