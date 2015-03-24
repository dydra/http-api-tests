#! /bin/bash
set -v
OBJECT_ID=provenance

set_sparql_url "${STORE_ACCOUNT}" "${STORE_REPOSITORY}-provenance"
curl_sparql_update  <<EOF \
 | jq '.boolean' | fgrep -q 'true'

DROP ALL
EOF

set_sparql_url "${STORE_ACCOUNT}" "${STORE_REPOSITORY}-write"
curl_sparql_update <<EOF \
 | jq '.boolean' | fgrep -q 'true'

PREFIX provenanceRepositoryID: <${STORE_ACCOUNT}/${STORE_REPOSITORY}-provenance>

DROP ALL ;
INSERT DATA {
 GRAPH <http://example.org/uri1/${OBJECT_ID}> {
  <http://example.org/uri1/one> <foaf:name> "object-${OBJECT_ID}" .
  <http://example.org/uri1/one> rdf:type <http://example.org/thing> .
 }
}
EOF


curl_graph_store_get -H "Accept: application/n-quads" "graph=http://example.org/uri1/${OBJECT_ID}" \
    --repository "${STORE_REPOSITORY}-write" \
  | rapper -q --input nquads --output nquads /dev/stdin - \
  | fgrep -q "object-${OBJECT_ID}"


# verify that the transaction graph has appeared in the provenance repository.
# for now, search the entire repository. the approach is necessary until some aspect of the the response
# provides information on the transaction to be used to determine the graph which was added to the provenance repository

curl_download -H "Accept: application/n-quads" 'nq' --repository "${STORE_REPOSITORY}-provenance \
  | cat # rapper -q --input nquads --output nquads /dev/stdin -  \
  #| fgrep "${OBJECT_ID}" | fgrep -q '<urn:dydra:Graph>'
