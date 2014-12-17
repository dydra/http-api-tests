#! /bin/bash

OBJECT_ID=$RANDOM

set_sparql_url "${STORE_ACCOUNT}" "${STORE_REPOSITORY}-provenance"
curl_sparql_update "Accept: application/sparql-results+json" <<EOF \
 | jq '.boolean' | fgrep -q 'true'

DROP ALL
EOF

set_sparql_url "${STORE_ACCOUNT}" "${STORE_REPOSITORY}-write"
curl_sparql_update "Accept: application/sparql-results+json" <<EOF \
 | jq '.boolean' | fgrep -q 'true'

PREFIX provenanceRepositoryID: <${STORE_ACCOUNT}/${STORE_REPOSITORY}-provenance>

INSERT DATA {
 GRAPH <http://example.org/uri1/${OBJECT_ID}> {
  <http://example.org/uri1/one> <foaf:name> "object-${OBJECT_ID}" .
  <http://example.org/uri1/one> rdf:type <http://example.org/thing> .
 }
}
EOF


set_graph_store_url "${STORE_ACCOUNT}" "${STORE_REPOSITORY}-write"
curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     -u "${STORE_TOKEN}:" \
     ${GRAPH_STORE_URL}?graph=http://example.org/uri1/${OBJECT_ID} \
  | rapper -q --input nquads --output nquads /dev/stdin - \
  | fgrep -q "object-${OBJECT_ID}"


# verify that transaction graph has appeared in the provenance repository.
# for now, search the entire repository. the approach is necessary until some aspect of the the response
# provides information on the transaction to be used to determine the graph which was added to the provenance repository

set_graph_store_url "${STORE_ACCOUNT}" "${STORE_REPOSITORY}-provenance"
curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     -u "${STORE_TOKEN}:" \
     ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}-provenance.nq \
  | rapper -q --input nquads --output nquads /dev/stdin -  \
  | fgrep "${OBJECT_ID}" | fgrep -q '<urn:dydra:Graph>'
