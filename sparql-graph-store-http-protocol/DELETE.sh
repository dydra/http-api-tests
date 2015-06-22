#! /bin/bash

# test that delete leaves an empty repository
initialize_repository --repository "${STORE_REPOSITORY}-write"

curl_graph_store_delete --repository "${STORE_REPOSITORY}-write"

curl_graph_store_get --repository "${STORE_REPOSITORY}-write" \
   | wc -l | fgrep -q 0

