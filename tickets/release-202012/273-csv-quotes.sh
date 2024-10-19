#! /bin/bash
#
# test, again, that quotes are present in csv results
# include the case where the solution is incomplete.
# in that case, no entry is present v/s the quoted blank string

curl_sparql_request \
     -H "Accept: text/csv" \
     -H "Content-Type:application/sparql-query" <<EOF \
 | sort -d | tee $ECHO_OUTPUT | diff --strip-trailing-cr -w - /dev/fd/2 2<<TEST
SELECT  ?id ?value
WHERE {
  VALUES (?id) {
   ( 'one' )
   ( 'two' )
  } optional {
    VALUES (?id ?value) {
      ( 'one' '123')
      ( 'one' '')
    }
  }
}
EOF
id,value
"one",""
"one","123"
"two",
TEST
