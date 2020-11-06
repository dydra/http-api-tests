#! /bin/bash

# test that delete leaves an empty repository
initialize_repository --repository "${STORE_REPOSITORY}-write"

# -o /tmp/gsp.ttl
curl_graph_store_delete -o /dev/null --repository "${STORE_REPOSITORY}-write"

curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
   | wc -l | fgrep -q 0

