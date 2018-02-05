#! /bin/sh

# test transcription admin operations
#
# clear
# enable/disable
# list all
# list individual

# GET yields the transcription list
$CURL -s -L -X GET -H "Accept: text/html" \
  -u ":${AUTH_TOKEN}" \
  "http://${STORE_HOST}/admin/transcription" \
 | fgrep -q "transcripts:"


# POST with no content disables
$CURL -s -L -X POST -H "Accept: text/html" \
  -u ":${AUTH_TOKEN}" \
  --data-urlencode '' \
  "http://${STORE_HOST}/admin/transcription" \
 | egrep -q -v 'state.*checked'


# POST with content enables
$CURL -s -L -X POST -H "Accept: text/html" \
  -u ":${AUTH_TOKEN}" \
  --data-urlencode 'state=on' \
  "http://${STORE_HOST}/admin/transcription" \
 | egrep -q 'state.*checked'

# a sparql request with transcription enabled should generate a transcript

# DELETE should remove all transcripts
$CURL -L -X DELETE -H "Accept: text/html" \
  -u ":${AUTH_TOKEN}" \
  "http://${STORE_HOST}/admin/transcription" \
 | egrep -q -v '[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}'

# use the endpoint which tests legacy transcription
$CURL -v -L -X POST -H "Accept: application/sparql-results+json" \
  -H "Content-Type: application/sparql-query" \
  -u ":${AUTH_TOKEN}" \
   --data-binary @- \
  "http://${STORE_HOST}/jhacker/foaf/dydra-query" <<EOF
select count(*) where {?s ?p ?o}
EOF

# '/opt/dydra/bin/dydra-query' 'jhacker/foaf' '-U' `uuidgen` '-o' 'application/sparql-results+json' '-D' 'agent-id=james' '-D' 'agent-location=92.208.13.60' '-D' 'revision-id=32542502-5853-1c47-aff2-5a73703e0625' <<EOF
# select count(*) where {?s ?p ?o}
# EOF

