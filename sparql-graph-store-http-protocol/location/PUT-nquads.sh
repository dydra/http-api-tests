#! /bin/bash

# put rdf+json from a remote location
# copy it from the default repository to the -write instance
# the request includes the Location header, but no content

initialize_repository --repository "${STORE_REPOSITORY}-write"

echo PUT-rj w/location PUT > $ECHO_OUTPUT
curl_graph_store_update -X PUT -o /dev/null \
    -H "Location: ${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/service" \
    -H "Content-Type: application/n-quads" \
    --repository "${STORE_REPOSITORY}-write" <<EOF
EOF

echo PUT-rj location GET > $ECHO_OUTPUT
curl_graph_store_get \
     -H "Accept: application/n-quads" --repository "${STORE_REPOSITORY}-write" \
   | tr -s '\n' '\t' \
   | fgrep "default object"  \
   | fgrep -q "named object"
