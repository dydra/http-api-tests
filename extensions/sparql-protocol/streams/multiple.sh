#!/bin/bash

# Initialization of variables
SENSOR_COUNT=100
SENSOR_NAME_PRECEDENCE='sensor_'
INPUT="./data/sensor_100.dat"

## Prepare repository
# Create graphs and sparql-queries for instance
for ((i=0; i<SENSOR_COUNT; i++))
do
   SENSORS[${i}]=$SENSOR_NAME_PRECEDENCE${i}

   ${CURL} -f -s -S -X POST \
        -H "Content-Type: application/sparql-query" \
        -H "Accept: application/sparql-results+json" \
        --data-binary @- \
        -u "${STORE_TOKEN}:" \
        https://dydra.com/skorkmaz/http_test/sparql <<EOF
        CREATE GRAPH <ex:${SENSORS[${i}]}>;
EOF
done

# Read input file, value - time pairs are in x,t format,
# multiple sensors x,t,x,t.x,t ... \n, where each line is a record
# for a different sample.
exec 3<"$INPUT"
while IFS='' read -r -u 3 line || [[ -n "$line" ]]; do
    arrIN=(${line//,/ })
    # Interactive upload, uncomment to use it
    # read -p "> $line (Press Enter to continue)"

# Setup query
QUERY=''
   for ((i=0; i<SENSOR_COUNT * 2; i=i+2))
       do
          QUERY=${QUERY}'INSERT DATA { GRAPH  <ex:'${SENSORS[${i}]}'>  {'${arrIN[${i}]}' dc:time '${arrIN[$(($i+1 ))]}';}};'
       done

# Make cURL requet with standard sparql query
${CURL} -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     -u "${STORE_TOKEN}:" \
     https://dydra.com/skorkmaz/http_test/sparql <<EOF
     $QUERY
EOF


done
