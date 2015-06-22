#! /bin/bash

curl_graph_store_get "graph=urn:dydra:service-description" \
  | rapper -q --input nquads --output nquads /dev/stdin - \
  | fgrep -q "http://www.w3.org/ns/sparql-service-description#Service"

