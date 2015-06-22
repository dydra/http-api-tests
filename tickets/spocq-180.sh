#! /bin/bash
#
# test that the exists operator is compiled in the correct field context.
# with the context, the expeced statement pattern variables are bound.
# absent the context, no variable is bound and the match succeeds where it is not intended to

curl_graph_store_update -X PUT \
     -H "Content-Type: application/n-quads" --repository ${STORE_REPOSITORY}-write <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate-too> "default object" .
EOF


curl_sparql_request \
     -H "Accept: application/sparql-results+json" \
     -H "Content-Type:application/sparql-query" <<EOF \
 | json_reformat -m \
 | egrep -q -s '"bindings".*"noNamed".*"value":false'
select ?subject ?noNamed
where {
  ?subject <http://example.com/default-predicate> ?object1
  BIND (NOT EXISTS { ?subject <http://example.com/named-predicate> ?object2 } as ?noNamed)
}
EOF

curl_sparql_request \
     -H "Accept: application/sparql-results+json" \
     -H "Content-Type:application/sparql-query"  <<EOF \
 | json_reformat -m \
 | egrep -q -s '"bindings".*"yesToo".*"value":true'
select ?subject ?noNamed
where {
  ?subject <http://example.com/default-predicate> ?object1
  BIND (EXISTS { ?subject <http://example.com/default-predicate-too> ?object2 } as ?yesToo)
}
EOF


initialize_repository | fgrep -q "${POST_SUCCESS}"
