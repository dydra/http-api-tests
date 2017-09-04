bishbosh_server=localhost
bishbosh_clientId='DydraToken'
bishbosh_connect_cleanSession=0

bishbosh_connection_handler_CONNACK()
{
    # Set up some subscriptions... another implementation could read from a standard file
    bishbosh_subscribe \
        '/dydra/stream/test' 0


    # Publish a QoS 0 message
    # On topic /dydra/stream/test
    # Unretained
    # With value Query

    #  A temporary simple test, file publish is failing, bish_bosh supported
    # file loop has to be added
    for VARIABLE in 1 2 3 4 5
    do
      bishbosh_publishText 0 '/dydra/stream/test' no 'INSERT DATA { GRAPH <ex:sensor_0> {0.0650852097492 dc:time 1504439170000;}};INSERT DATA { GRAPH <ex:sensor_2> {0.00838105914086 dc:time 1504439170000;}};INSERT DATA { GRAPH <ex:sensor_4> {-0.130554703864 dc:time 1504439170000;}};INSERT DATA { GRAPH <ex:sensor_6> {-0.0333081962029 dc:time 1504439170000;}};INSERT DATA { GRAPH <ex:sensor_8> {-0.0942477217154 dc:time 1504439170000;}};INSERT DATA { GRAPH <ex:> {-0.16466598977 dc:time 1504439170000;}};INSERT DATA { GRAPH <ex:> {-0.0808522610705 dc:time 1504439170000;}};INSERT DATA { GRAPH <ex:> {0.0998330640103 dc:time 1504439170000;}};INSERT DATA { GRAPH <ex:> {0.105343651461 dc:time 1504439170000;}};INSERT DATA { GRAPH <ex:> {-0.115738199739 dc:time 1504439170000;}};'
    done

}
