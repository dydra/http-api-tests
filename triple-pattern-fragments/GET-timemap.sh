#! /bin/bash

# test timegate generation

$CURL -f -s -X GET \
  -u "${STORE_TOKEN}:" \
  "${STORE_URL}/${STORE_ACCOUNT}/${STORE_REPOSITORY}/tpf?graph=urn%3Adydra%3Atimemap" > result.nq

fgrep -s 'openrdf-sesame/mem-rdf' result.nq \
  | fgrep -q 'mementoweb.org/terms/tb/timeGateFor'
fgrep -s 'openrdf-sesame/mem-rdf' result.nq \
  | fgrep -q 'www.mementoweb.org/terms/tb/TimeGate'
fgrep -s 'openrdf-sesame/mem-rdf' result.nq \
  | fgrep -q 'www.openarchives.org/ore/terms/ResourceMap'

