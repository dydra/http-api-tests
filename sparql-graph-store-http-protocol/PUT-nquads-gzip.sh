#! /bin/bash

# test content-encoding: gzip for turtle

initialize_repository --repository "${STORE_REPOSITORY}-write"

echo '<http://example.com/default-subject> <http://example.com/default-predicate> "default object PUT1" .' \
  | gzip \
  | curl_graph_store_update -X PUT --data-binary @- -o /dev/null \
     -H "Content-Encoding: gzip"\
     -H "Content-Type: application/n-quads" \
     --repository "${STORE_REPOSITORY}-write" 

curl_graph_store_get \
     --repository "${STORE_REPOSITORY}-write" \
   | tr -s '\n' '\t' \
   | fgrep -v '"default object"' | fgrep -v '"named object"' | fgrep -v "<${STORE_NAMED_GRAPH}>" \
   | fgrep '"default object PUT1"' \
   | tr -s '\t' '\n' | wc -l | fgrep -q 1
