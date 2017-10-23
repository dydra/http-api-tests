#! /bin/bash

# simple test, that the metadata repository exists

curl_graph_store_get --repository "system" \
     -H "Accept: application/n-quads" \
  | fgrep 'http://www.w3.org/ns/auth/acl#accessTo' \
  | fgrep -q "${STORE_ACCOUNT}/${STORE_REPOSITORY}"
