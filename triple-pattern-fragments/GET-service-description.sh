#! /bin/bash

# test service description generation

$CURL -f -s -X GET \
  -u "${STORE_TOKEN}:" \
  "${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/tpf?graph=urn%3Adydra%3AserviceDescription" > result.nq

fgrep -s 'openrdf-sesame/mem-rdf' result.nq \
  | fgrep -q 'www.w3.org/ns/sparql-service-description#Service'
fgrep -s 'openrdf-sesame/mem-rdf' result.nq \
  | fgrep -q 'www.w3.org/ns/sparql-service-description#endpoint'
fgrep -s 'openrdf-sesame/mem-rdf' result.nq \
  | fgrep -q 'www.w3.org/ns/sparql-service-description#defaultDataset'

