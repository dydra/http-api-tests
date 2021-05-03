#! /bin/bash
set -o errexit

# executed for varied service endpoint and content/accept media types,
# with expected variations in the available options
# nb. -D - means no data

# gsp
curl_graph_store_get -D - -X OPTIONS \
   | fgrep -i "Allow" | fgrep GET | fgrep -q DELETE

# there are no restrictions on request media type
curl_graph_store_get -D - -f -s -X OPTIONS \
     -H "Content-Type: application/sparql-query" \
   | fgrep -i "Allow" | fgrep GET | fgrep PUT | fgrep POST | fgrep -q DELETE

# there are no restrictions on response media type
curl_graph_store_get -D - -f -s -X OPTIONS \
     -H "Accept: application/sparql-results+xml" \
   | fgrep -i "Allow" | fgrep PUT | fgrep POST | fgrep -q DELETE


# verify that headers are those required by preflight requests
# even where the actual request would yield a 401
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Headers
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Origin
#
# the fetch document permts and 200
# https://fetch.spec.whatwg.org/

STORE_TOKEN="not valid" curl_graph_store_get -D - -f -s -X OPTIONS \
  --repository "system" \
  --account "system" \
  | tr '\n' ' ' | tr '\r' ' ' \
  | fgrep -i 'Access-Control-Allow-Origin' \
  | fgrep -i 'Access-Control-Allow-Credentials' \
  | fgrep -q 200

