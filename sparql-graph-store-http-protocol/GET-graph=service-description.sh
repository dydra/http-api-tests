#! /bin/bash

curl_graph_store_get "graph=urn:dydra:service-description" \
  | rapper -q --input nquads --output nquads /dev/stdin - \
  | tr '\n' ' ' \
  | fgrep -s "http://www.w3.org/ns/sparql-service-description#Service" \
  | fgrep -s 'www.w3.org/ns/sparql-service-description#endpoint' \
  | fgrep -q 'www.w3.org/ns/sparql-service-description#defaultDataset'

