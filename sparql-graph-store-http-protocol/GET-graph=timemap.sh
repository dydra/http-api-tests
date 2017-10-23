#! /bin/bash

# test timegate generation

curl_graph_store_get "graph=urn%3Adydra%3Atimemap" > result.nq

fgrep -s 'openrdf-sesame/mem-rdf' result.nq \
  | fgrep -q 'mementoweb.org/terms/tb/timeGateFor'
fgrep -s 'openrdf-sesame/mem-rdf' result.nq \
  | fgrep -q 'www.mementoweb.org/terms/tb/TimeGate'
fgrep -s 'openrdf-sesame/mem-rdf' result.nq \
  | fgrep -q 'www.openarchives.org/ore/terms/ResourceMap'

