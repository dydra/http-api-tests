#! /bin/bash

# test the minimal content of a service description
# a GET with no query _and_ no content type should generate one.

curl_sparql_request -X GET -H "Accept: text/turtle" -H "Content-Type: " \
 | rapper -q --input turtle --output nquads /dev/stdin - \
 | tee service-description.ttl \
 | fgrep -q 'http://www.w3.org/ns/sparql-service-description#Service'


