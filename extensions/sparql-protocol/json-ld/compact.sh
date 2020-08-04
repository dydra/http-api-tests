#! /bin/bash

# test for compact v/s non-compact json-ld result document

# compact
STORE_ACCOUNT=json-ld curl_sparql_request \
  --repository "foaf" \
  -H "Accept: application/ld+json" \
  'query=describe%20?s%20where%20%20%7b?s%20?p%20?o%7d' \
  | fgrep -q -v '<http://xmlns.com/foaf/0.1/Person>'

# non-compact
STORE_ACCOUNT=json-ld curl_sparql_request \
  --repository "foaf" \
  -H "Accept: application/ld+json;profile=\"http://www.w3.org/ns/json-ld#expanded\"" \
  'query=describe%20?s%20where%20%20%7b?s%20?p%20?o%7d' \
  | fgrep -q '<http://xmlns.com/foaf/0.1/Person>'
