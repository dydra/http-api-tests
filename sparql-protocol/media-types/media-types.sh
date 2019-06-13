#! /bin/bash
# exercise responses for supported media types

set -e

function test_media_type() {
  local mime="$1";
  local query="$2";
  local mime_file=`echo $mime | sed -e 's./._.' `;
  local ref_file="${mime_file}.ref"
  local new_file="${mime_file}.new"

  echo "request: ${mime}" > $ECHO_OUTPUT
  curl_sparql_request -H "Accept: ${mime}" --repository mem-rdf-write <<EOF \
  | sed -e 's/.0E0"/.0"/' | sed -e 's/.0E0</.0</g'  | sed -e 's/.0E0,/.0,/g' > ${new_file}
$query
EOF
  echo "test ${ref_file} v/s ${new_file} " > $ECHO_OUTPUT
  if [[ -e ${ref_file} ]]
  then
    diff -q ${ref_file} ${new_file}
    rm ${new_file} # if the test succeeded 
  else
    mv ${new_file} ${ref_file}
  fi
}

curl_graph_store_update -X PUT -o /dev/null \
     -H "Content-Type: application/trig" \
     --repository "${STORE_REPOSITORY}-write" < media-types.trig

test_media_type application/n-quads "construct {?s ?p ?o} where { {graph ?g {?s ?p ?o}} union {?s ?p ?o} }"

test_media_type text/turtle "construct {?s ?p ?o} where { {graph ?g {?s ?p ?o}} union {?s ?p ?o} }"

 # supported for import only
 # test_media_type application/trig "construct {?s ?p ?o} where { {graph ?g {?s ?p ?o}} union {?s ?p ?o} }"

test_media_type application/trix "construct {?s ?p ?o} where { {graph ?g {?s ?p ?o}} union {?s ?p ?o} }"

test_media_type application/ld+json "construct {?s ?p ?o} where { {graph ?g {?s ?p ?o}} union {?s ?p ?o} }"

test_media_type application/rdf+xml "construct {?s ?p ?o} where { {graph ?g {?s ?p ?o}} union {?s ?p ?o} }"

test_media_type application/sparql-results+xml "select * where { {graph ?g {?s ?p ?o}} union {?s ?p ?o} }"

test_media_type application/sparql-results+json "select * where { {graph ?g {?s ?p ?o}} union {?s ?p ?o} }"

test_media_type text/csv "select * where { {graph ?g {?s ?p ?o}} union {?s ?p ?o} }"

test_media_type application/sparql-results+json-columns-streaming "select * where { {graph ?g {?s ?p ?o}} union {?s ?p ?o} }"

 # does not work as post.
 # requires a get to a view
 # test_media_type application/sparql-results+jsonp "select * where { {graph ?g {?s ?p ?o}} union {?s ?p ?o} }"
 # test_media_type application/javascript "select * where { {graph ?g {?s ?p ?o}} union {?s ?p ?o} }"

test_media_type text/tab-separated-values "select * where { {graph ?g {?s ?p ?o}} union {?s ?p ?o} }"

test_media_type application/json "select * where { {graph ?g {?s ?p ?o}} union {?s ?p ?o} }"


cat > /dev/null <<EOF
(test-sparql "select * where {graph ?g {?s ?p ?o}}"
             :repository-id "openrdf-sesame/mem-rdf-write"
             :response-content-type mime:application/sparql-results+json)
EOF

