#! /bin/bash

URL='localhost'
PORT='1883'
REQUEST_ENDPOINT='/request'
RESPONSE_ENDPOINT='/response'
# Initialization of variables
SENSOR_COUNT=5
SENSOR_NAME_PRECEDENCE='sensor_'
INPUT="./data/sensor_100.dat"
# Temporary file for queries
OUTPUT=~/data.dat

rm -f $OUTPUT

cat $OUTPUT
for ((i=0; i<SENSOR_COUNT; i++))
do
   SENSORS[${i}]=$SENSOR_NAME_PRECEDENCE${i}
done

# Read input file, value - time pairs are in x,t format,
# multiple sensors x,t,x,t.x,t ... \n where each line is a record
# for a different sample.
exec 3<"$INPUT"
while IFS='' read -r -u 3 line || [[ -n "$line" ]]; do
    arrIN=(${line//,/ })
    # Interactive upload, uncomment to use it
    # read -p "> $line (Press Enter to continue)"

# Setup query
QUAD=''
   for ((i=0; i<SENSOR_COUNT * 2; i=i+2))
       do
          GRAPH_INDEX=($i/2)
          # Quad instance
          QUAD=${arrIN[${i}]}' <dc:time> '${arrIN[$(($i+1 ))]}' <ex:'${SENSORS[${GRAPH_INDEX}]}'>'
          echo $QUAD >> $OUTPUT

       done
done

python libraries/mqtt/mqtt_client.py $URL $PORT $STORE_TOKEN $REQUEST_ENDPOINT $RESPONSE_ENDPOINT $OUTPUT
