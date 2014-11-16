#! /bin/bash
#
# test that the exists operator is compiled in the correct field context.
# with the context, the expeced statement pattern variables are bound.
# absent the context, no variable is bound and the match succeeds where it is not intended to

${CURL} -w "%{http_code}\n" -L -f -s -X PUT \
     -H "Content-Type: application/n-quads" --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY_PUBLIC}?auth_token=${STORE_TOKEN} <<EOF
<http://example.com/default-subject> <http://example.com/default-predicate-too> "default object" .
EOF


curl -f -s -S -X POST \
     -H "Accept: application/sparql-results+json" \
     -H "Content-Type:application/sparql-query" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} <<EOF \
 | json_reformat -m \
 | egrep -q -s '"bindings".*"noNamed".*"value":false'
select ?subject ?noNamed
where {
  ?subject <http://example.com/default-predicate> ?object1
  BIND (NOT EXISTS { ?subject <http://example.com/named-predicate> ?object2 } as ?noNamed)
}
EOF

curl -f -s -S -X POST \
     -H "Accept: application/sparql-results+json" \
     -H "Content-Type:application/sparql-query" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?auth_token=${STORE_TOKEN} <<EOF \
 | json_reformat -m \
 | egrep -q -s '"bindings".*"yesToo".*"value":true'
select ?subject ?noNamed
where {
  ?subject <http://example.com/default-predicate> ?object1
  BIND (EXISTS { ?subject <http://example.com/default-predicate-too> ?object2 } as ?yesToo)
}
EOF


initialize_repository | fgrep -q "${POST_SUCCESS}"
