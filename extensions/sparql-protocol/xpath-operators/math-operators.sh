#! /bin/bash

# exercise the math operators

# require non-null values to be present for all functions
curl_sparql_request "Accept: application/sparql-results+json" <<EOF \
 | jq '.results.bindings[] | [.acos, .asin, .atan, .atan2, .cos, .exp, .exp10, .log, .log10, .pi, .pow, .sin, .sqrt, .tan] | map(.value)' \
 | fgrep '"' | fgrep -v null | wc -l | fgrep -q '14'

prefix math: <http://www.w3.org/2005/xpath-functions/math#>
select (math:acos(1) as ?acos)
       (math:asin(1) as ?asin)
       (math:atan(1) as ?atan)
       (math:atan2(1, 0) as ?atan2)
       (math:cos(math:pi()) as ?cos)
       (math:exp(1) as ?exp)
       (math:exp10(1) as ?exp10)
       (math:log(1) as ?log)
       (math:log10(1) as ?log10)
       (math:pi() as ?pi)
       (math:pow(2, 2) as ?pow)
       (math:sin(0) as ?sin)
       (math:sqrt(2) as ?sqrt)
       (math:tan(1) as ?tan)
where { }
EOF


# check that each signals a condition for invalid arguments
curl_sparql_request "Accept: application/sparql-results+json" <<EOF \
 | jq '.results.bindings[] | [.acos, .asin, .atan, .atan2, .cos, .exp, .exp10, .log, .log10, .pi, .pow, .sin, .sqrt, .tan] | map(.value)' \
 | fgrep null | wc -l | fgrep -q '13'

prefix math: <http://www.w3.org/2005/xpath-functions/math#>
select (math:acos('1') as ?acos)
       (math:asin('1') as ?asin)
       (math:atan('1') as ?atan)
       (math:atan2('1', 0) as ?atan2)
       (math:cos(math:pi()) as ?cos)
       (math:exp('1') as ?exp)
       (math:exp10('1') as ?exp10)
       (math:log('1') as ?log)
       (math:log10('1') as ?log10)
       # accepts no argument (math:pi() as ?pi)
       (math:pow('2', 2) as ?pow)
       (math:sin('0') as ?sin)
       (math:sqrt('2') as ?sqrt)
       (math:tan('1') as ?tan)
where { }
EOF