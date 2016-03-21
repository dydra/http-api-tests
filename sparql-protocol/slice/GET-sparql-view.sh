#! /bin/bash

# verify slice arguments for sparql views
# as long as the respone limit is under that from the query text, it will reduce the response count

query="all-no-limit"

$CURL -u "${STORE_TOKEN}:" "http://dydra.com/openrdf-sesame/mem-rdf/all-no-limit.tsv?limit=1" \
  | wc -l | fgrep -q -s '2'

$CURL -u "${STORE_TOKEN}:" \
  "http://dydra.com/openrdf-sesame/mem-rdf/all-no-limit.tsv?limit=1&offset=1" \
  | wc -l | fgrep -q -s '2'

$CURL -u "${STORE_TOKEN}:" "http://dydra.com/openrdf-sesame/mem-rdf/all.tsv?limit=1" \
  | wc -l | fgrep -q -s '2'


$CURL -u "${STORE_TOKEN}:" \
  "http://dydra.com/openrdf-sesame/mem-rdf/all-no-limit.csv?limit=1"\
  | wc -l | fgrep -q -s '2'

$CURL -u "${STORE_TOKEN}:" \
  "http://dydra.com/openrdf-sesame/mem-rdf/all.csv?limit=1" \
  | wc -l | fgrep -q -s '2'

$CURL -u "${STORE_TOKEN}:" \
  "http://dydra.com/openrdf-sesame/mem-rdf/all-no-limit.srj?limit=1" \
  | fgrep -c '"o":' | fgrep -q -s '1'

$CURL -u "${STORE_TOKEN}:" \
  "http://dydra.com/openrdf-sesame/mem-rdf/all.srj?limit=1"\
  | fgrep -c '"o":' | fgrep -q -s '1'

$CURL -u "${STORE_TOKEN}:" \
  "http://dydra.com/openrdf-sesame/mem-rdf/all-no-limit.srx?limit=1" \
  | fgrep -c 'binding name="g"' | fgrep -q -s '1'

$CURL -u "${STORE_TOKEN}:" \
  "http://dydra.com/openrdf-sesame/mem-rdf/all.srx?limit=1" \
  | fgrep -c 'binding name="g"' | fgrep -q -s '1'

# NTF
# $CURL -u "${STORE_TOKEN}:" "http://dydra.com/openrdf-sesame/mem-rdf/${query}.jsonp?limit=1" | fgrep -q -s-v "],["

# when jsonp
# 2016-03-21T08:52:30.601368+00:00 [debug] ool dydra-admin: Spawning: exec '/opt/dydra/bin/dydra-query' 'openrdf-sesame/mem-rdf' '-U' 'ee34b433-2d04-49a9-860a-b3f22572916c' '-o' 'application/json' '-D' 'agent-id=james' '-D' 'agent-location=94.219.69.66'
# when tsv
# 2016-03-21T08:53:15.806306+00:00 [debug] ool dydra-query: Spawning: exec '/opt/dydra/bin/dydra-query' 'openrdf-sesame/mem-rdf' '-U' '1206b632-0769-41ef-a43a-0ad3b9e61646' '-o' 'text/tab-separated-values' '-D' 'agent-id=james' '-D' 'agent-location=94.219.69.66' '-D' 'limit=1'

