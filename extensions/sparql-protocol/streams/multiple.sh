# Initialization of variables
SENSOR_COUNT=5
SENSOR_NAME_PRECEDENCE='sensor_'

## Prepare repository
# Create graphs and sparql-queries for instance
for ((i=1; i<=SENSOR_COUNT; i++))
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
    read -p "> $line (Press Enter to continue)"
QUERY=''
for ((i=1; i<=SENSOR_COUNT; i++))
do
  QUERY=${QUERY}'INSERT DATA { GRAPH  <ex:'${SENSORS[${i}]}'>  {'${arrIN[0]}' dc:time '${arrIN[1]}';}};'
done
${CURL} -f -s -S -X POST \
     -H "Content-Type: application/sparql-query" \
     -H "Accept: application/sparql-results+json" \
     --data-binary @- \
     -u "${STORE_TOKEN}:" \
     https://dydra.com/skorkmaz/http_test/sparql <<EOF
     $QUERY
EOF

done
