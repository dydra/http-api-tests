#! /bin/bash
set -o errexit

# test without regards to exclusions based on content type
# as the php implementation has no logic to distinguish
# nb. -D - means no data

# sparql query content combines with post only
curl_sparql_request -D - -X OPTIONS\
     -H "Content-Type: application/sparql-query" \
   | fgrep -i "Allow" | fgrep PUT | fgrep GET | fgrep POST | fgrep -q HEAD


