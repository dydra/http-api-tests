#! /bin/bash

curl_sparql_request \
     -H "Accept: application/sparql-results+xml" \
     'query=select%20(count(*)%20as%20%3Fcount1)%20where%20%7B%3Fs%20%3Fp%20%3Fo%7D' \
   | xmllint  --c14n11 - \
   | tr -s '\t\n\r\f' ' ' | sed 's/ +/ /g' | sed 's/></> </g' \
   | fgrep 'variable name="count1"' \
   | egrep -q -s '<binding name="count1"> <literal .*>1</literal>'
