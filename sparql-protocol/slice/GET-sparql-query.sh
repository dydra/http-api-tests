#! /bin/bash

# verify slice arguments for queries provided in-line

query="select%20*%20where%20%7B%20%7B%20graph%20%3Fg%20%7B%3Fs%20%3Fp%20%3Fo%7D%20%7D%20union%20%7B%3Fs%20%3Fp%20%3Fo%7D%20%7D"

curl_sparql_request \
      'response-limit=1' \
      -H "Accept: text/csv" "query=${query}" \
   | wc -l | fgrep -q -s '2'

curl_sparql_request \
      'limit=1' 'offset=1' \
      -H "Accept: text/csv" "query=${query}" \
   | wc -l | fgrep -q -s '2'

curl_sparql_request \
      'response-limit=1' \
      -H "Accept: application/sparql-results+xml" "query=${query}" \
   | fgrep -c 'binding name="o"' | fgrep -q -s '1'

curl_sparql_request \
      'limit=1' 'offset=1' \
      -H "Accept: application/sparql-results+xml" "query=${query}" \
   | fgrep -c 'binding name="o"' | fgrep -q -s '1'

curl_sparql_request \
      'response-limit=1' \
      -H "Accept: application/sparql-results+json" "query=${query}" \
   | fgrep -c '"o":' | fgrep -q -s '1'

curl_sparql_request \
      'limit=1' 'offset=1' \
      -H "Accept: application/sparql-results+json" "query=${query}" \
   | fgrep -c '"o":' | fgrep -q -s '1'
