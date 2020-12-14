#! /bin/bash
#
# test that the language strings encoding uses just the '"' character

curl_sparql_request \
     -H "Accept: application/ld+json" \
     -H "Content-Type:application/sparql-query" <<EOF \
 | tee $ECHO_OUTPUT | fgrep '{"@language":"en", "@value":"a"}'
CONSTRUCT {
  <http://example.org/subject> <http://example.org/predicate> ?string
}
WHERE {
  VALUES (?string) {
    ( 'a'@en )
  }
}
EOF