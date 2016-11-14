#! /bin/bash

# exercise the query inspection extensions

#STORE_URL="${STORE_URL}:82"
#curl_sparql_request \
$CURL \
  --data-binary @- \
  -H "Content-Type: application/sparql-query" \
  -H "Accept: application/sparql-query-algebra" \
  'http://stage.dydra.com:82/james/test/sparql' <<EOF \
  | cat # fgrep -sqi 'Project'
select count(*) where {?s ?p ?o}
EOF

$CURL \
  -H "Accept: application/sparql-query-algebra" \
  'http://stage.dydra.com:82/james/test/sparql?query=select%20count(*)%20where%20%7b?s%20?p%20?o%7d'

$CURL \
  --data-binary @- \
  -H "Content-Type: application/sparql-query" \
  -H "Accept: application/vnd.dydra.sparql-query-algebra" \
  'http://stage.dydra.com:82/james/test/sparql' <<EOF \
  | fgrep -sq '(select'
select count(*) where {?s ?p ?o}
EOF

$CURL \
  --data-binary @- \
  -H "Content-Type: application/sparql-query" \
  -H "Accept: application/vnd.dydra.sparql-query-plan" \
  'http://stage.dydra.com:82/james/test/sparql' <<EOF \
  | fgrep -sq 'AGGREGATE'
select count(*) where {?s ?p ?o}
EOF

$CURL \
  --data-binary @- \
  -H "Content-Type: application/sparql-query" \
  -H "Accept: application/vnd.dydra.sparql-results-execution+json" \
  'http://stage.dydra.com:82/james/test/sparql' <<EOF \
  | fgrep -sq '"OP": "aggregate"'
select count(*) where {?s ?p ?o}
EOF

$CURL \
  --data-binary @- \
  -H "Content-Type: application/sparql-query" \
  -H "Accept: TEXT/VND.DYDRA.SPARQL-RESULTS-EXECUTION+GRAPHVIZ" \
  'http://stage.dydra.com:82/james/test/sparql' <<EOF \
  | fgrep -sq 'digraph'
select count(*) where {?s ?p ?o}
EOF


$CURL \
  --data-binary @- \
  -H "Content-Type: application/sparql-query" \
  -H "Accept: image/VND.DYDRA.SPARQL-RESULTS-EXECUTION+GRAPHVIZ+SVG+XML" \
  'http://stage.dydra.com:82/james/test/sparql' <<EOF \
  | fgrep -sq 'DOCTYPE svg'
select count(*) where {?s ?p ?o}
EOF


$CURL \
  --data-binary @- \
  -H "Content-Type: application/sparql-query" \
  -H "Accept: application/VND.DYDRA.SPARQL-RESULTS-EXECUTION+GRAPHVIZ+PDF" \
  'http://stage.dydra.com:82/james/test/sparql' <<EOF \
  | cat > /tmp/tmp.pdf ; file /tmp/tmp.pdf | fgrep -sqi 'pdf'
select count(*) where {?s ?p ?o}
EOF

