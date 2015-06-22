#! /bin/bash

initialize_repository --repository "${STORE_REPOSITORY}-write"

curl_graph_store_update -X PUT \
     -H "Content-Type: application/trix" \
     --repository "${STORE_REPOSITORY}-write" graph=http://dydra.com/trix-graph-name <<EOF
<TriX>
<graph>
  <uri>http://dydra.com/trix-graph-name</uri>
  <triple>
   <uri>http://example.com/default-subject</uri>
   <uri>http://example.com/default-predicate</uri>
   <plainLiteral>default object . PUT-trix</plainLiteral>
  </triple>
</graph>
</TriX>
EOF

curl_graph_store_get \
     -H "Accept: application/n-quads" --repository "${STORE_REPOSITORY}-write" \
   | tr -s '\n' '\t' \
   | fgrep 'trix-graph-name' | fgrep -q 'PUT-trix'

