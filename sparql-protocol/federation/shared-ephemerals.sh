#! /bin/bash
# federated subselects must share ephemeral terms

curl_sparql_request \
     -H "Content-Type: application/sparql-update" \
     -H "Accept: application/sparql-results+json" <<EOF \
   | jq '.results.bindings | .[].count.value' | fgrep -q '"1"'
select (count(*) as ?count) where {
 { ?s1 <http://example.com/default-predicate> ?o1
    bind (concat(?o1, '++') as ?o_plus)
 }
 { service  <http://localhost/openrdf-sesame/mem-rdf> {
     ?s2 <http://example.com/default-predicate> ?o2
      bind (concat(?o2, '++') as ?o_plus)
   }
 }
}
EOF
