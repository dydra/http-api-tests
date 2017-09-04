#!/bin/bash


SENSOR_ID='sensor_0'
INPUT="./data/sensor_1.dat"
SENSOR_DATA=''
SENSOR_TIME=''
DELIMITER=','

#Create one graph
${CURL} -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     -u "${STORE_TOKEN}:" \
     http://dydra.com/skorkmaz/http_test/sparql <<EOF
     CREATE GRAPH <ex:${SENSOR_ID}>;
EOF

# Push data via SPARQL endpoint
exec 3<"$INPUT"
while IFS='' read -r -u 3 line || [[ -n "$line" ]]; do
    arrIN=(${line//,/ })
    # Comment out for disabling command line based interaction before push
    #read -p "> $line (Press Enter to continue)"
${CURL} -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     -u "${STORE_TOKEN}:" \
     http://dydra.com/skorkmaz/http_test/sparql <<EOF
     INSERT DATA { GRAPH  <ex:${SENSOR_ID}>  {${arrIN[0]} dc:time ${arrIN[1]};}}
EOF

done
