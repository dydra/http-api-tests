#! /bin/bash

# sparql results for a construct should return a 406

curl -w "%{http_code}\n" -f -s -X GET \
     -H "Accept: application/sparql-results+xml" \
     -u "${STORE_TOKEN}:" \
     "${SPARQL_URL}"'?query=construct%20%7B%20%3Fs%20%3Fp%20%3Fo%20%7D%20where%20%7B%20%3Fs%20%3Fp%20%3Fo%20%7D%20' \
   | fgrep -q "${STATUS_NOT_ACCEPTABLE}"
