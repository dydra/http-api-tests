#! /bin/bash

CURL="${CURL} -w '%{http_code}\n' -s"
set_graph_store_url ${STORE_ACCOUNT} ${STORE_REPOSITORY}-not
curl_graph_store_get "Accept: application/n-quads" "default" \
   | fgrep -q "${STATUS_NOT_FOUND}"

