#! /bin/bash
#
# test that repeated variables are compiled properly

curl_sparql_request \
     --repository "${STORE_REPOSITORY}" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | tee $ECHO_OUTPUT \
   | fgrep COUNT | fgrep -q '"1"'
select count(*)
where {
 ?s ?p ?o .
 filter (?o != 2 && ?o != 2 || ?o != 3)
}
EOF



