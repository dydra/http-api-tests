#! /bin/bash
set -o errexit

# executed for varied service endpoint and content/accept media types,
# with expected variations in the available options
# nb. -D - means no data

curl_graph_store_get -D - -X OPTIONS \
   | fgrep "Allow" | fgrep GET | fgrep -q DELETE

# there are no restrictions on request media type
curl_graph_store_get -D - -f -s -X OPTIONS\
     -H "Content-Type: application/sparql-query" \
   | fgrep "Allow" | fgrep GET | fgrep PUT | fgrep POST | fgrep -q DELETE

# there are no restrictions on response media type
curl_graph_store_get -D - -f -s -X OPTIONS\
     -H "Accept: application/sparql-results+xml" \
   | fgrep "Allow" | fgrep PUT | fgrep POST | fgrep -q DELETE


# sparql
# grap request content yields no implementation
curl_sparql_request -D - -X OPTIONS\
     -H "Content-Type: application/n-quads" \
   | fgrep "Allow" | fgrep -v POST | fgrep -v GET | fgrep -q HEAD
# sparql query content combines with post only
curl_sparql_request -D - -X OPTIONS\
     -H "Content-Type: application/sparql-query" \
   | fgrep "Allow" | fgrep POST | fgrep -v GET | fgrep -q HEAD
# no content combines with get only
curl_sparql_request -D - -X OPTIONS\
     -H "Content-Type: " \
   | fgrep "Allow" | fgrep -v POST | fgrep GET | fgrep -q HEAD

