## README for MQTT tests

Requirements:

-Python 2.7
-paho-mqtt library

You can install the paho-mqtt library using pip

-pip install paho-mqtt

# How to run

You should first run define.sh
 - source define.sh
Then you can run each individual shell script as ;  
 - source extensions/mqtt/test.sh

 -'STORE_TOKEN': This variable should be available in global context,
 defined in define.sh


# SPAQRL queries

 SPARQL queries are generated for MQTT python script to perform upload to
 specified server which has information declared in the script itself.
 They are defined in test.sh

# N-Quads

 Due to being lightweight and has Prefixes added into packages, another
 test case is packing sensor data in RDF format, following n-quads schema.
 This case utilizes graph field as a denoting field for id of each sensor,
 it is required to enter an explicit value which is supported in N-quad unlike
 N-Triples
 MQTT payload size does support up to 256 megabytes.
