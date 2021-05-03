#! /bin/bash

# exercise the query introspection extensions

curl_sparql_request \
  -H "Content-Type: application/sparql-query" \
  -H "Accept: application/sparql-query-algebra" <<EOF \
  | fgrep -sqi 'Project'
select count(*) where {?s ?p ?o}
EOF

curl_sparql_request -X GET \
  'query=select%20count(*)%20where%20%7b?s%20?p%20?o%7d' \
  -H "Content-Type: " \
  -H "Accept: application/sparql-query-algebra" \
  | fgrep -sqi 'Project'


curl_sparql_request \
  -H "Content-Type: application/sparql-query" \
  -H "Accept: application/vnd.dydra.sparql-query-plan" <<EOF \
  | fgrep -sq '(AGGREGATE'
select count(*) where {?s ?p ?o}
EOF

curl_sparql_request \
  -H "Content-Type: application/sparql-query" \
  -H "Accept: application/vnd.dydra.sparql-results-execution+json" <<EOF \
  | egrep -sq '"OP":.*"aggregate"'
select count(*) where {?s ?p ?o}
EOF

curl_sparql_request \
  -H "Content-Type: application/sparql-query" \
  -H "Accept: TEXT/VND.DYDRA.SPARQL-RESULTS-EXECUTION+GRAPHVIZ" <<EOF \
  | fgrep -sq 'digraph'
select count(*) where {?s ?p ?o}
EOF


curl_sparql_request \
  -H "Content-Type: application/sparql-query" \
  -H "Accept: image/VND.DYDRA.SPARQL-RESULTS-EXECUTION+GRAPHVIZ+SVG+XML" <<EOF \
  | fgrep -sq 'DOCTYPE svg'
select count(*) where {?s ?p ?o}
EOF


tmpfile="$(mktemp /tmp/tmp-XXXXXX).pdf"
curl_sparql_request \
  -H "Content-Type: application/sparql-query" \
  -H "Accept: application/VND.DYDRA.SPARQL-RESULTS-EXECUTION+GRAPHVIZ+PDF"  <<EOF \
  | cat > $tmpfile # ; file $tmpfile | fgrep -sqi 'pdf'
select count(*) where {?s ?p ?o}
EOF

