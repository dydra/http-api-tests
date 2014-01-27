#! /bin/bash

# provenance 6/1648 and 6/1649

OBJECT_ID=$RANDOM
curl -w "%{http_code}\n" -f -s -S -X POST \
     -H "Content-Type: application/sparql-update" \
     --data-binary @- \
     ${STORE_URL}/jhacker/726-base?auth_token=${STORE_TOKEN} <<EOF \
  | fgrep 201
PREFIX provenanceRepositoryID: <jhacker/726-provenance>

INSERT DATA {
 GRAPH <http://example.org/uri1/${OBJECT_ID}> {
  <http://example.org/uri1/one> <foaf:name> "object-${OBJECT_ID}" .
  <http://example.org/uri1/one> rdf:type <http://example.org/thing> .
 }
}
EOF

curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     ${STORE_URL}/jhacker/726-provenance?auth_token=${STORE_TOKEN} \
   | rapper -q --input nquads --output nquads /dev/stdin - | tr -s '\n' '\t' \
   | fgrep "object-${OBJECT_ID}" | fgrep -q '/thing' 


curl -f -s -S -X GET\
     -H "Accept: application/n-quads" \
     ${STORE_URL}/jhacker/726-provenance?auth_token=${STORE_TOKEN} \
   | rapper -q --input nquads --output nquads /dev/stdin - | tr -s '\n' '\t' \
   | fgrep -q 'http://example.org/uri1/${OBJECT_ID}'


