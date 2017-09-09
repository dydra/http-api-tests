import paho.mqtt.client as paho
import threading
import sys

def publish_1(client,topic, f_loc):
    print "publishing data"
    f = open(f_loc, "r")
    lst_queries =  f.readlines()
    for q in lst_queries:
        client.publish(topic, q)
        print q
    client.loop_stop()


def on_connect(client, userdata, flags, rc):
    print "CONNACK received with code "  + str(rc)

def on_subscribe(client, userdata, mid, granted_qos):
    print("Subscribed: "+str(mid)+" "+str(granted_qos))

def on_message(client, userdata, msg):
    print(msg.topic+" "+str(msg.qos)+" "+str(msg.payload))



url            = sys.argv[1]
port           = sys.argv[2]
token          = sys.argv[3]
request_topic  = sys.argv[4]
response_topic = sys.argv[5]
f_loc          = sys.argv[6]

client = paho.Client(token)
client.on_connect = on_connect
client.on_subscribe = on_subscribe
client.on_message = on_message
client.connect(url, port)
client.loop_start()
thread1=threading.Thread(target=publish_1,args=(client,request_topic, f_loc))
thread1.start()
