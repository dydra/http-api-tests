#! /bin/bash
#
# test that a parsed value iri (from the filter) is identical with one where the parsed
# value has been stored and retrieved.
# the same test should apply to blank nodes, but there is no way to bind one

curl_sparql_request \
     -H "Accept: text/csv" \
     -H "Content-Type:application/sparql-query" <<EOF \
 | tee $ECHO_OUTPUT | sort | diff -w - /dev/fd/2 2<<TEST
select * where {
  values ?a { 0 1 }
  values ?b { true false }
}
EOF
0,false
0,true
1,false
1,true
a,b
TEST