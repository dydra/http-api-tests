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


# this actually tests that the filter is not folded into the values clause

curl_sparql_request \
     -H "Accept: application/sparql-results+json" \
     -H "Content-Type:application/sparql-query" <<EOF \
 | tee $ECHO_OUTPUT | fgrep COUNT | fgrep -q '"1"'
SELECT count(*) WHERE {
    VALUES (?this ?Type) {
    ( <https://localhost:4443/admin/acl/agents/e413f97b-15ee-47ea-ba65-4479aa7f1f9e/>
      <https://localhost:4443/admin/ns#AgentItem> )
 }
 FILTER (?Type = <https://localhost:4443/admin/ns#AgentItem>)
}
EOF


# test when it is folded into the bgp

curl_sparql_request \
     -H "Accept: application/sparql-results+json" \
     -H "Content-Type:application/sparql-query" <<EOF \
 | tee $ECHO_OUTPUT | fgrep COUNT | fgrep -q '"1"'
SELECT count(*) WHERE {
 ?s ?p ?o .
 FILTER (?p IN (<http://example.com/default-predicate>))
}
EOF


# test that unknown terms do not intefere with those which are known

curl_sparql_request \
     -H "Accept: application/sparql-results+json" \
     -H "Content-Type:application/sparql-query" <<EOF \
 | tee $ECHO_OUTPUT | fgrep COUNT | fgrep -q '"1"'
SELECT count(*) WHERE {
 ?s ?p ?o .
 FILTER (?p IN (<http://example.com/default-predicate>,
                <http://example.com/unknown-predicate>))
}
EOF

