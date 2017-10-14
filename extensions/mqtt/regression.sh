# Simple call to read from mqtt topic to perform a simple linear regression
# Retrieves data from REQUEST_ENDPOINT and pushes prediction via RESPONSE_ENDPOINT

URL='localhost'
PORT='1883'
REQUEST_ENDPOINT='/request'
RESPONSE_ENDPOINT='/response'
SENSOR_COUNT=5
SENSOR_NAME_PRECEDENCE='sensor_'
# Machine Learning Provider (MLP)
AGENT_TYPE='MLP'

python libraries/mqtt/mqtt_client_ML.py $URL $PORT $STORE_TOKEN $REQUEST_ENDPOINT $RESPONSE_ENDPOINT $OUTPUT $AGENT_TYPE
