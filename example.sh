# using the shell functions

# get with accept
curl_sparql_request -H "Accept: application/sparql-results+json" 'query=select%20count(*)%20where%20%7b?s%20?p%20?o%7d'

# get allowing default accept
curl_sparql_request 'query=select%20count(*)%20where%20%7b?s%20?p%20?o%7d'

# post query with accept
curl_sparql_request -H "Accept: application/sparql-results+xml" <<EOF
select * where { { graph ?g {?s ?p ?o} } union {?s ?p ?o} } limit 10
EOF

# post query allowing default accept
curl_sparql_request <<EOF
select * where { { graph ?g {?s ?p ?o} } union {?s ?p ?o} } limit 10
EOF

# post query with accept
curl_sparql_request -H "Content_Type: application/sparql-query" <<EOF
select * where { { graph ?g {?s ?p ?o} } union {?s ?p ?o} } limit 10
EOF

# invoke curl directly

${CURL} -w "%{http_code}\n" -f -s -S -X PUT \
     -H "Content-Type: text/plain" \
     --data-binary @triples.nt \
     http://stage.dydra.com/openrdf-sesame/repositories/mem-rdf/statements?auth_token=${STORE_TOKEN} 

${CURL} -w "%{http_code}\n" -f -s -S -X PUT \
     -H "Content-Type: text/plain" \
     --data-binary @triples.nt \
     http://stage.dydra.com/openrdf-sesame/mem-rdf/service?auth_token=${STORE_TOKEN} 

${CURL} -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     -u "${STORE_TOKEN}:" \
     http://stage.dydra.com/openrdf-sesame/mem-rdf/sparql <<EOF 
prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>
prefix fn: <http://www.w3.org/2005/xpath-functions#>
select ((xsd:yearMonthDuration('P1Y1M') = xsd:yearMonthDuration('P1Y1M'))
        as ?ok)
where {
 }
EOF
