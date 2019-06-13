#! /bin/bash

initialize_repository --repository "${STORE_REPOSITORY}-write"

curl_graph_store_update -X PUT -o /dev/null \
     -H "Content-Type: application/rdf+json" \
     --repository "${STORE_REPOSITORY}-write" <<EOF
{ "http://example.com/default-subject" : {
  "http://example.com/default-predicate" : [ { "value" : "default object PUT-rj",
                                               "type" : "literal" } ]
  },
  "http://example.com/named-subject" : {
  "http://example.com/named-predicate" : [ { "value" : "named object PUT-rj",
                                               "type" : "literal" } ]
  }
}
EOF

curl_graph_store_get \
     -H "Accept: application/n-quads" --repository "${STORE_REPOSITORY}-write" \
   | tr -s '\n' '\t' \
   | fgrep "default object PUT-rj"  \
   | fgrep -q "named object PUT-rj"


