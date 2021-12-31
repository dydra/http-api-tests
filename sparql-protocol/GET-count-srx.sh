#! /bin/bash

curl_sparql_request -H "Accept: application/sparql-results+xml" 'query=select%20count(*)%20where%20%7b?s%20?p%20?o%7d' \
   | xmllint  --c14n11 - \
   | tr -s '\t\n\r\f' ' ' | sed 's/ +/ /g' \
   | egrep -i 'variable name="count.*"' \
   | egrep -i -q -s '<binding name="count.*">.*<literal .*>1</literal>'
