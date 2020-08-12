#! /bin/bash
#
# test that a parsed value iri (from the filter) is identical with one where the parsed
# value has been stored and retrieved.
# the same test should apply to blank nodes, but there is no way to bind one

curl_sparql_request \
     -H "Accept: application/sparql-results+json" \
     -H "Content-Type:application/sparql-query" <<EOF \
 | tee $ECHO_OUTPUT | fgrep COUNT | fgrep -q '"1"'
SELECT count(*) WHERE {
  VALUES (?this ?Type) {
    ( <https://localhost:4443/admin/acl/agents/e413f97b-15ee-47ea-ba65-4479aa7f1f9e/>
       <https://localhost:4443/admin/ns#AgentItem> )
  }
  FILTER ((?this IN (<https://localhost:4443/admin/acl/agents/e413f97b-15ee-47ea-ba65-4479aa7f1f9e/>))
          )
           
}
EOF
