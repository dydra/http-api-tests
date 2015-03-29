#! /bin/bash

curl_sparql_request \
     -H "Accept: application/rdf+xml" \
     'query=construct%20%7B%20%3Fs%20%3Fp%20%3Fo%20%7D%20where%20%7B%20%3Fs%20%3Fp%20%3Fo%20%7D%20' \
   | rapper -q --input rdfxml --output nquads /dev/stdin - \
   | fgrep -q "default object"
