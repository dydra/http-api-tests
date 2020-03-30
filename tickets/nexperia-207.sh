#! /bin/bash
#
# test that repeated variables are compiled propery

curl_sparql_request \
     --repository "${STORE_REPOSITORY}-write" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | fgrep -c count | fgrep -q 1
select count(*)
where {
 ?s ?p ?o .
 filter (?o != 2 && ?o != 2 || ?o != 3)
}
EOF



