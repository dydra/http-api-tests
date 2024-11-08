#! /bin/bash

# exercise the duration comparison operators

curl_sparql_request <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q 'true'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>
prefix fn: <http://www.w3.org/2005/xpath-functions#>

select (((xsd:yearMonthDuration('P1Y1M') = xsd:yearMonthDuration('P1Y1M')) &&
         (xsd:yearMonthDuration('P1Y1M') = xsd:yearMonthDuration('P13M')) &&
         (!(xsd:yearMonthDuration('P1M') = xsd:yearMonthDuration('P1Y'))) &&
         (xsd:dayTimeDuration('P1D') = xsd:dayTimeDuration('P1D')) &&
         (xsd:dayTimeDuration('P1D') = xsd:dayTimeDuration('PT24H')) &&
         (xsd:dayTimeDuration('P1D') = xsd:dayTimeDuration('PT1440M')) &&
         (xsd:dayTimeDuration('P1D') = xsd:dayTimeDuration('PT86400S')) &&
         (xsd:dayTimeDuration('P1DT12H') = xsd:dayTimeDuration('PT2160M')) &&
         (xsd:dayTimeDuration('P1D') = xsd:dayTimeDuration('PT24H')) &&
         
         # tests from XPath and XQuery Functions and Operators 3.0 section 8.2.5 op:duration-equal
         (xsd:duration("P1Y") = xsd:duration("P12M")) &&
         (xsd:duration("PT24H") = xsd:duration("P1D")) &&
         (!(xsd:duration("P1Y") = xsd:duration("P365D"))) &&
         (xsd:yearMonthDuration('P0Y') = xsd:dayTimeDuration('P0D')) &&
         (! (xsd:yearMonthDuration('P1Y') = xsd:dayTimeDuration('P365D'))) &&
         (xsd:yearMonthDuration("P2Y") = xsd:yearMonthDuration("P24M")) &&
         (xsd:dayTimeDuration("P10D") = xsd:dayTimeDuration("PT240H")) &&
         (xsd:duration('P2Y0M0DT0H0M0S') = xsd:yearMonthDuration('P24M')) &&
         (xsd:duration('P0Y0M10D') = xsd:dayTimeDuration('PT240H'))
         )
        as ?ok)
where {
 }
EOF

# (spocq.e:= ({xsd}duration "P1Y")  ({xsd}duration "P365D"))
# (spocq.e:= ({xsd}duration "P0Y0M10D")  ({xsd}yearMonthDuration "P24M"))
# (spocq.e:= ({xsd}duration "P0Y0M10D")  ({xsd}dayTimeDuration "PT240H"))
# (spocq.e:= ({xsd}dayTimeDuration "P1D")  ({xsd}dayTimeDuration "PT24H"))
# (spocq.e:= ({xsd}yearMonthDuration "P0Y")  ({xsd}dayTimeDuration "P0D"))
#  (spocq.e:! (spocq.e:= ({xsd}yearMonthDuration "P1Y")  ({xsd}dayTimeDuration "P365D")))
# ({xsd}duration "P3Y")
