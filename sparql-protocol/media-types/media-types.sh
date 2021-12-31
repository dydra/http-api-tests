#! /bin/bash
# exercise responses for supported media types

set -e

query="construct {?s ?p ?o} where { {graph ?g {?s ?p ?o}} union {?s ?p ?o} } order by ?s ?p ?o"
function test_media_type () {
  local mime="$1";
  mime_file=`echo $mime | sed -e 's./._.' `
  test_media_type_with $mime $mime_file;
}

function test_media_type_with () {
  local mime="$1";
  local mime_file="$2";
  local ref_file="${mime_file}.ref"
  local new_file="${mime_file}.new"

  echo "request: ${mime}" "${new_file}" > $ECHO_OUTPUT
  curl_sparql_request -H "Accept: ${mime}" --repository mem-rdf-write <<EOF \
    | tee ${ECHO_OUTPUT} \
    | sed -e 's/.0E0"/.0"/' | sed -e 's/.0E0</.0</g'  | sed -e 's/.0E0,/.0,/g' > ${new_file}
$query
EOF
#  if [[ "" != "$sort" ]]
#  then
#    echo "sort: ${mime}" > $ECHO_OUTPUT
#    sort ${new_file} > /tmp/${new_file}
#    cp /tmp/${new_file} ${new_file}
#    rm /tmp/${new_file}
#  fi
  echo "test ${ref_file} v/s ${new_file} " > $ECHO_OUTPUT
  if [[ -s ${ref_file} ]]
  then
    diff -w --strip-trailing-cr ${ref_file} ${new_file}
    #rm ${new_file} # if the test succeeded 
  else
    mv ${new_file} ${ref_file}
  fi
}

curl_graph_store_update -X PUT -o /dev/null \
     -H "Content-Type: application/trig" \
     --repository "${STORE_REPOSITORY_WRITABLE}" < media-types.trig

test_media_type application/n-quads  sort
test_media_type text/turtle
# supported for import only
# test_media_type application/trig
test_media_type application/trix
# specify compact or expand (default is a service configuration)
#test_media_type application/ld+json 
test_media_type_with 'application/ld+json;profile="http://www.w3.org/ns/json-ld#compacted"' application_ld+json_compacted
test_media_type_with 'application/ld+json;profile="http://www.w3.org/ns/json-ld#expanded"' application_ld+json_expanded
test_media_type application/rdf+xml
test_media_type application/sparql-results+xml
test_media_type application/sparql-results+json
test_media_type text/csv
test_media_type text/tab-separated-values
test_media_type application/sparql-results+json-columns-streaming
test_media_type application/json

# does not work as post.
# requires a get to a view
# test_media_type application/sparql-results+jsonp
# test_media_type application/javascript

test_media_type text/tab-separated-values
test_media_type application/json


# for manual comparison
cat > /dev/null <<EOF
(test-sparql "select * where { {graph ?g {?s ?p ?o}} union {?s ?p ?o} } order by ?s ?p ?o"
             :repository-id "openrdf-sesame/mem-rdf-write"
             ; :response-content-type mime:application/sparql-results+json
)
(test-sparql "construct {?s ?p ?o} where { {graph ?g {?s ?p ?o}} union {?s ?p ?o} } order by ?s ?p ?o"
             :repository-id "openrdf-sesame/mem-rdf-write"
             :response-content-type (mime-type "application/ld+json;profile=\"http://www.w3.org/ns/json-ld#compacted\"")
             ; :response-content-type (mime-type "application/ld+json;profile=\"http://www.w3.org/ns/json-ld#expanded\"")
             ; :response-content-type mime:application/ld+json
             ;:response-content-type mime:text/turtle
)
EOF


cat > /dev/null <<EOF
curl_sparql_request -H "Accept: application/trix" --repository mem-rdf-write <<END
construct { ?s <http://www.w3.org/2001/XMLSchema#string> ?o}
where {
  {graph ?g {?s <http://www.w3.org/2001/XMLSchema#string> ?o}}
  union
  {?s <http://www.w3.org/2001/XMLSchema#string> ?o} 
}
order by ?s ?p ?o
END

curl_sparql_request -H "Accept: text/csv" --repository mem-rdf-write <<END
construct { ?s <http://example.org/special> ?o}
where {
  {?s <http://example.org/special> ?o} 
}
order by ?s ?p ?o
END

curl_sparql_request -H "Accept: application/n-quads" --repository mem-rdf-write <<END
construct { ?s <http://example.org/special> ?o}
where {
  {?s <http://example.org/special> ?o} 
}
order by ?s ?p ?o
END

curl_sparql_request -H "Accept: application/trix" --repository mem-rdf-write <<END
construct { ?s ?p ?o}
where {
  {?s ?p ?o} 
}
order by ?s ?p ?o
END

curl_sparql_request -H "Accept: text/tab-separated-values" --repository mem-rdf-write <<END
construct { ?s ?p ?o}
where {
  {?s ?p ?o} 
}
order by ?s ?p ?o
END

curl_sparql_request -H 'Accept: application/ld+json;profile="http://www.w3.org/ns/json-ld#compacted"' --repository mem-rdf-write <<END
construct { ?s ?p ?o}
where {
  {?s ?p ?o} 
}
order by ?s ?p ?o
END

curl_sparql_request -H 'Accept: application/ld+json;profile="http://www.w3.org/ns/json-ld#expanded"' --repository mem-rdf-write <<END
construct { ?s ?p ?o}
where {
  {?s ?p ?o} 
}
order by ?s ?p ?o
END


dydra-import -i application/n-quads -X PUT openrdf-sesame/mem-rdf-write /dev/stdin <<END
<http://example.org/default> <http://example.org/special> "string with comma (,)" .
<http://example.org/default> <http://example.org/special> "string with comma (,)"^^<http://example.org/special> .
<http://example.org/default> <http://example.org/special> "special string with comma (,)"^^<http://example.org/special> .
END

dydra-import -i application/n-quads -X PUT openrdf-sesame/mem-rdf-write /dev/stdin <<END
#<http://example.org/default> <http://www.w3.org/2001/XMLSchema#int> "-2147483648"^^<http://www.w3.org/2001/XMLSchema#int> .
<http://example.org/default> <http://www.w3.org/2001/XMLSchema#int> "2147483647"^^<http://www.w3.org/2001/XMLSchema#int> .
#<http://example.org/default> <http://www.w3.org/2001/XMLSchema#long> "9223372036854775807"^^<http://www.w3.org/2001/XMLSchema#long> .
#<http://example.org/default> <http://www.w3.org/2001/XMLSchema#integer> "-10"^^<http://www.w3.org/2001/XMLSchema#integer> .
#<http://example.org/default> <http://www.w3.org/2001/XMLSchema#integer> "10"^^<http://www.w3.org/2001/XMLSchema#integer> .
<http://example.org/default> <http://www.w3.org/2001/XMLSchema#integer> "0"^^<http://www.w3.org/2001/XMLSchema#integer> .
END


curl_graph_store_update -X PUT -o /dev/null \
     -H "Content-Type: application/trig" \
     --repository "${STORE_REPOSITORY_WRITABLE}" < media-types-int.trig

curl_graph_store_update -X PUT -o /dev/null \
     -H "Content-Type: application/trig" \
     --repository "${STORE_REPOSITORY_WRITABLE}" < media-types-date.trig

EOF
