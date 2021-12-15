#! /bin/bash

# exercise strbon period operators

curl_sparql_request revision-id=HEAD <<EOF \
   | tee $ECHO_OUTPUT | fgrep -c 'true' | fgrep -q "1"
prefix dydra: <http://dydra.com/sparql-functions#>
prefix strdf: <http://strdf.di.uoa.gr/ontology#>
prefix time: <http://www.w3.org/2006/time#>
select ?test_equals

where {
    bind(now() as ?t0)
    bind(?t0 + xsd:dayTimeDuration('P1D') as ?t1)
    bind(?t0 + xsd:dayTimeDuration('P2D') as ?t2)
    bind(?t0 + xsd:dayTimeDuration('P3D') as ?t3)
    bind(?t0 + xsd:dayTimeDuration('P4D') as ?t4)
    bind(?t0 + xsd:dayTimeDuration('P5D') as ?t5)

    bind(time:dateTimeInterval(?t2, ?t4) as ?b)

    bind(strdf:period(?t0, ?t1) as ?p1)
    bind(strdf:period(?t1, ?t0) as ?p2)
    bind(strdf:equals(?p1, ?p2) as ?test_equals)
}
EOF

curl_sparql_request revision-id=HEAD <<EOF \
   | tee $ECHO_OUTPUT | fgrep -c 'true' | fgrep -q "2"
prefix dydra: <http://dydra.com/sparql-functions#>
prefix strdf: <http://strdf.di.uoa.gr/ontology#>
prefix time: <http://www.w3.org/2006/time#>
select ?test_equals1 ?test_equals2

where {
    bind(now() as ?t0)
    bind(?t0 + xsd:dayTimeDuration('P1D') as ?t1)
    bind(?t0 + xsd:dayTimeDuration('P2D') as ?t2)
    bind(?t0 + xsd:dayTimeDuration('P3D') as ?t3)
    bind(?t0 + xsd:dayTimeDuration('P4D') as ?t4)
    bind(?t0 + xsd:dayTimeDuration('P5D') as ?t5)

    bind(time:dateTimeInterval(?t2, ?t4) as ?b)

    bind(time:dateTimeInterval(?t0, ?t1) as ?a_precedes)
    bind(time:dateTimeInterval(?t0, ?t2) as ?a_meets)
    bind(time:dateTimeInterval(?t0, ?t3) as ?a_overlaps)
    bind(time:dateTimeInterval(?t0, ?t4) as ?a_finished_by)
    bind(time:dateTimeInterval(?t0, ?t5) as ?a_contains)
    bind(time:dateTimeInterval(?t2, ?t3) as ?a_starts)

    bind(strdf:equals(strdf:period-preceding(?a_overlaps, ?b), ?a_meets) as ?test_equals1)
    bind(strdf:equals(strdf:periodPreceding(?a_overlaps, ?b), ?a_meets) as ?test_equals2)
}
EOF

