import paho.mqtt.client as paho
import threading
import random
import time
import sys


def publish_agent(client,topic, f_loc):
    print "publishing data"
    f = open(f_loc, "r")
    lst_queries =  f.readlines()
    for q in lst_queries:
        client.publish(topic, q)
        print q
    client.loop_stop()

def publish_MLP(client,topic):
    # Publishes random prediction
    # N-Quads format
    query = "<http://example.com/model_1> <http://www.w3.org/ns/sosa/Result> " + str(random.random()) + " <g_:"+str(int(time.time()))+"> ."
    client.publish(topic, query)

def subscribe(client, topic):
    print "subscribing to topic"
    client.subscribe(topic)

def on_subscribe(client, userdata, mid, granted_qos):
    print("Subscribed: "+str(mid)+" "+str(granted_qos))

def on_connect(client, userdata, flags, rc):
    print "CONNACK received with code "  + str(rc)

def on_connect_MLP(client, userdata, flags, rc):
    client.subscribe(request_topic)
    print "CONNACK received with code "  + str(rc)

def on_message(client, userdata, msg):
    print(msg.topic+" "+str(msg.qos)+" "+str(msg.payload))

def on_message_MLP(client, userdata, msg):
    print "MLP got data, publishing prediction to response topic ..:"
    print(msg.topic+" "+str(msg.qos)+" "+str(msg.payload))
    publish_MLP(client,response_topic)


url            = sys.argv[1]
port           = sys.argv[2]
token          = sys.argv[3]
request_topic  = sys.argv[4]
response_topic = sys.argv[5]
f_loc          = sys.argv[6]
agent_type     = sys.argv[7]


client = paho.Client(token)

if agent_type == 'MLP':
    client.on_message = on_message_MLP
    client.on_connect = on_connect_MLP
else:
    client.on_message = on_message
    client.on_connect = on_connect

client.on_subscribe = on_subscribe
client.on_message = on_message
client.connect(url, port)
client.loop_start()

if agent_type == 'MLP':
    client.loop_forever()

else:
    thread_mqtt = threading.Thread(target=publish_agent, args=(client,request_topic, f_loc))
    thread_mqtt.start()
