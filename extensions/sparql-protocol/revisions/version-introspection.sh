#! /bin/bash

# exercise version introspection

curl_sparql_request revision-id=HEAD <<EOF \
   | tee $ECHO_OUTPUT | egrep -c '"version.*: ' | fgrep -q "6"
prefix dydra: <http://dydra.com/sparql-functions#>
select (dydra:version-start-date-time(dydra:version()) as ?versionStartDate)
       (dydra:version-start-ordinal(dydra:version()) as ?versionStartOrdinal)
       (dydra:version-start-uuid(dydra:version()) as ?versionStartUUID)
       (dydra:version-end-date-time(dydra:version()) as ?versionEndDate)
       (dydra:version-end-ordinal(dydra:version()) as ?versionEndOrdinal)
       (dydra:version-end-uuid(dydra:version()) as ?versionEndUUID)
where {}
EOF






