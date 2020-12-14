#! /bin/bash
#
# verify that all csv strings appear with '"' markings
# verify that just that character is escaped, while eol is not

curl_sparql_request \
     -H "Accept: text/csv" \
     -H "Content-Type:application/sparql-query" <<EOF \
  | tee $ECHO_OUTPUT | tee ./test.csv | diff -w - /dev/fd/2 2<<TEST
select * where {
  values ?v {
    "8 inch diameter"
    "8\" diameter"
    '8" diameter'
    '''first
second
8 " diameter'''
  }
}
EOF
v
"8 inch diameter"
"8"" diameter"
"8"" diameter"
"first
second
8 "" diameter"
TEST

curl_sparql_request \
     -H "Accept: application/sparql-results+json" \
     -H "Content-Type:application/sparql-query" <<EOF \
  | tee $ECHO_OUTPUT | fgrep type | diff -w - /dev/fd/2 2<<TEST
select * where {
  values ?v {
    "8 inch diameter"
    "8\" diameter"
    '8" diameter'
    '''first
second
8 " diameter'''
  }
}
EOF
 { "v": {"type":"literal", "datatype":"http://www.w3.org/2001/XMLSchema#string", "value":"8 inch diameter"} },
 { "v": {"type":"literal", "datatype":"http://www.w3.org/2001/XMLSchema#string", "value":"8\" diameter"} },
 { "v": {"type":"literal", "datatype":"http://www.w3.org/2001/XMLSchema#string", "value":"8\" diameter"} },
 { "v": {"type":"literal", "datatype":"http://www.w3.org/2001/XMLSchema#string", "value":"first\nsecond\n8 \" diameter"} } ] } }
TEST
