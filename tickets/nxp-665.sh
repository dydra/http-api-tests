#! /bin/bash
#
# confirm filter clause order in combination with bind/extend

curl_sparql_request \
     -H "Accept: text/csv" \
     -H "Content-Type:application/sparql-query" <<EOF \
 | tee $ECHO_OUTPUT \
 | wc | fgrep -q -s '3'
select *
where  {
 ?s ?p ?o .
 bind (1 as ?v)
 filter(bound(?o))
}
EOF
