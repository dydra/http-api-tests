#! /bin/bash

# exercise interval constructors and predicates
# check datatypes and successful counts

curl_sparql_request revision-id=HEAD <<EOF \
   | tee $ECHO_OUTPUT | fgrep -c 'DateTimeInterval' | fgrep -q "6"
prefix dydra: <http://dydra.com/sparql-functions#>
prefix strdf: <http://strdf.di.uoa.gr/ontology#>
prefix time: <http://www.w3.org/2006/time#>
select ?a_precedes ?a_meets ?a_overlaps ?a_finished_by ?a_contains ?a_starts

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
}
EOF

curl_sparql_request revision-id=HEAD <<EOF \
   | tee $ECHO_OUTPUT | fgrep -c 'true' | fgrep -q "14"
prefix dydra: <http://dydra.com/sparql-functions#>
prefix strdf: <http://strdf.di.uoa.gr/ontology#>
prefix time: <http://www.w3.org/2006/time#>
select *

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

    bind(strdf:precedes(?a_precedes, ?b) as ?test_precedes)
    bind(strdf:preceded-by(?b, ?a_precedes) as ?test_preceded_by)
    bind(strdf:meets(?a_meets, ?b) as ?test_meets)
    bind(strdf:met-by(?b, ?a_meets) as ?test_met_by)
    bind(strdf:overlaps(?a_overlaps, ?b) as ?test_overlaps)
    bind(strdf:overlapped-by(?b, ?a_overlaps) as ?test_overlapped_by)
    bind(strdf:finished-by(?a_finished_by, ?b) as ?test_finished_by)
    bind(strdf:finishes(?b, ?a_finished_by) as ?test_finishes)
    bind(strdf:contains(?a_contains, ?b) as ?test_contains)
    bind(strdf:during(?b, ?a_contains) as ?test_during)
    bind(strdf:starts(?a_starts, ?b) as ?test_starts)
    bind(strdf:started-by(?b, ?a_starts) as ?test_started_by)
    bind(strdf:equals(?b, ?b) as ?test_equals)
    bind(strdf:nequals(?b, ?a_precedes) as ?test_nequals)
}
EOF

curl_sparql_request revision-id=HEAD <<EOF \
   | tee $ECHO_OUTPUT | fgrep -c 'false' | fgrep -q "14"
prefix dydra: <http://dydra.com/sparql-functions#>
prefix strdf: <http://strdf.di.uoa.gr/ontology#>
prefix time: <http://www.w3.org/2006/time#>
select *

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

    bind(strdf:preceded-by(?a_precedes, ?b) as ?test_precedes)
    bind(strdf:precedes(?b, ?a_precedes) as ?test_preceded_by)
    bind(strdf:met-by(?a_meets, ?b) as ?test_meets)
    bind(strdf:meets(?b, ?a_meets) as ?test_met_by)
    bind(strdf:overlapped-by(?a_overlaps, ?b) as ?test_overlaps)
    bind(strdf:overlaps(?b, ?a_overlaps) as ?test_overlapped_by)
# arguments for starting and finishing exchanged because that are symmetric 
    bind(strdf:finishes(?a_starts, ?b) as ?test_finished_by)
    bind(strdf:finished-by(?b, ?a_starts) as ?test_finishes)
    bind(strdf:during(?a_contains, ?b) as ?test_contains)
    bind(strdf:contains(?b, ?a_contains) as ?test_during)
    bind(strdf:started-by(?a_finished_by, ?b) as ?test_starts)
    bind(strdf:starts(?b, ?a_finished_by) as ?test_started_by)
    bind(strdf:nequals(?b, ?b) as ?test_equals)
    bind(strdf:equals(?b, ?a_precedes) as ?test_nequals)
}
EOF


curl_sparql_request revision-id=HEAD <<EOF \
   | tee $ECHO_OUTPUT | fgrep -c 'true' | fgrep -q "17"
prefix dydra: <http://dydra.com/sparql-functions#>
prefix strdf: <http://strdf.di.uoa.gr/ontology#>
prefix time: <http://www.w3.org/2006/time#>
select *

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

    bind(strdf:precedes(?t0, ?b) as ?test_precedes1)
    bind(strdf:precedes(?t1, ?b) as ?test_precedes2)
    bind(strdf:preceded-by(?b, ?t0) as ?test_preceded_by1)
    bind(strdf:preceded-by(?b, ?t1) as ?test_preceded_by2)
    bind(strdf:meets(?t2, ?b) as ?test_meets)
    bind(strdf:met-by(?b, ?t2) as ?test_met_by)
    bind(strdf:overlaps(?t3, ?b) as ?test_overlaps)
    bind(strdf:overlapped-by(?b, ?t3) as ?test_overlapped_by)
    bind(strdf:finished-by(?t4, ?b) as ?test_finished_by)
    bind(strdf:finishes(?b, ?t4) as ?test_finishes)
    # location cannot contain bind(strdf:contains(?a_contains, ?b) as ?test_contains)
    bind(strdf:during(?t2, ?a_contains) as ?test_during1)
    bind(strdf:during(?t4, ?a_contains) as ?test_during2)
    bind(strdf:starts(?t2, ?b) as ?test_starts)
    bind(strdf:started-by(?b, ?t2) as ?test_started_by)
    # location equality requires empty interval
    bind(strdf:equals(?t0, time:dateTimeInterval(?t0, ?t0)) as ?test_equals)
    bind(strdf:nequals(?t1, ?a_precedes) as ?test_nequals1)
    bind(strdf:nequals(?t0, time:dateTimeInterval(?t1, ?t1)) as ?test_nequals2)
}
EOF


