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
 filter (?o != 'a' && ?o != 'a' || ?o != 'c')
}
EOF



cat >/dev/null <<EOF
(expand-query "
(test-sparql "
# the initial version used these number constants.
# the fail as they are not comparale
select count(*)
where {
 ?s ?p ?o .
 filter (?o != 1 && ?o != 1 || ?o != 3)
}
"
:repository-id "openrdf-sesame/mem-rdf"
:agent (system-agent))
EOF
