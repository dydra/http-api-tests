#! /bin/sh

curl -v -L -X POST -H "Accept: application/sparql-results+json" \
 --data "select * where { { graph ?g {?s ?p ?o} } union {?s ?p ?o} } " \
-H "Content-Type: application/sparql-query" \
'http://de8.dydra.com/skorkmaz/qa_test/dydra-query'
