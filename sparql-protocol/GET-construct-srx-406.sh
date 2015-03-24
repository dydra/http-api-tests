#! /bin/bash

# sparql results for a construct should return a 406

curl_sparql_request -w "%{http_code}\n" \
     -H "Accept: application/sparql-results+xml" \
     'query=construct%20%7B%20%3Fs%20%3Fp%20%3Fo%20%7D%20where%20%7B%20%3Fs%20%3Fp%20%3Fo%20%7D%20' \
   | test_not_acceptable_success
