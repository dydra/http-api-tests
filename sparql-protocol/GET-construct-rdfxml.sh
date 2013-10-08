#! /bin/bash

curl -f -s -X GET \
     -H "Accept: application/rdf+xml" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}?'query=construct%20%7B%20%3Fs%20%3Fp%20%3Fo%20%7D%20where%20%7B%20%3Fs%20%3Fp%20%3Fo%20%7D%20'\&auth_token=${STORE_TOKEN} \
   | rapper -q --input rdfxml --output nquads /dev/stdin - \
   | fgrep -q "default object"
