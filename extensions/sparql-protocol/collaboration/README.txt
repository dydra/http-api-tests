these tests are to exercise different collaboration access settings:

access      direct       collaboartion
            none         read
            read         read
            read/write   read
            none         read/write
            read         read/write
            read/write   read/write

most of the tests are NYI
just the write component of the last is implemented in sparql-graph-store-http-protocol/PUT-collaboration.sh .
