#! /bin/bash

initialize_repository --repository "${STORE_REPOSITORY}-write"

curl_graph_store_update -X PUT -o /dev/null \
     -H "Content-Type: application/rdf+xml" \
     --repository "${STORE_REPOSITORY}-write" <<EOF
<?xml version="1.0" encoding="utf-8"?>
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <rdf:Description rdf:about="http://example.com/default-subject">
    <ns0:default-predicate xmlns:ns0="http://example.com/">default object . PUT-rdfxml</ns0:default-predicate>
  </rdf:Description>
</rdf:RDF>
EOF

curl_graph_store_get \
     -H "Accept: application/n-quads" --repository "${STORE_REPOSITORY}-write" \
   | fgrep -q 'default object . PUT-rdfxml'
