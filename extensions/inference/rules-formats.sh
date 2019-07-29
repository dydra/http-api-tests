#! /bin/bash
#
# test rdfs rules and their interpretation

# set up the rules
curl_graph_store_update -X PUT   -w "%{http_code}\n" -o /dev/null \
     -H "Content-Type: text/turtle" \
     --repository "inference"  <<EOF \
   | test_put_success
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
<https://www.w3.org/TR/rdf11-mt/rdfs9#antecedant>
    <http://www.w3.org/2000/10/swap/log/implies> <https://www.w3.org/TR/rdf11-mt/rdfs9#consequent> .

<urn:dydra:entailment:rdfs2>
    <http://spinrdf.org/spin#body> [
        <http://spinrdf.org/sp#text> "construct {?subject a ?type} where {?predicate rdfs:domain ?type . ?subject ?predicate ?object}"^^<http://www.w3.org/2001/XMLSchema#string> ;
        a <http://spinrdf.org/sp#Construct>
    ] ;
    a <http://spinrdf.org/spin#ConstructTemplate> .

<urn:dydra:entailment:rdfs3>
    <http://spinrdf.org/spin#body> [
        <http://spinrdf.org/sp#text> "construct {?object a ?type} where {?predicate rdfs:range ?type . ?subject ?predicate ?object}"^^<http://www.w3.org/2001/XMLSchema#string> ;
        a <http://spinrdf.org/sp#Construct>
    ] ;
    a <http://spinrdf.org/spin#ConstructTemplate> .

<urn:dydra:entailment:rdfs7>
    <http://spinrdf.org/sp#text> "construct {?subject ?predicate ?object} where {?subject ?subPredicate ?object . ?subPredicate rdfs:subPropertyOf ?predicate.}"^^<http://www.w3.org/2001/XMLSchema#string> ;
    <http://www.w3.org/2000/01/rdf-schema#label> "rdfs7"^^<http://www.w3.org/2001/XMLSchema#string> .

<urn:dydra:entailment:rdfs9>
    <http://www.w3.org/2000/01/rdf-schema#label> "rdfs 9"^^<http://www.w3.org/2001/XMLSchema#string> ;
    <http://www.w3.org/2000/10/swap/log/antecedent> <https://www.w3.org/TR/rdf11-mt/rdfs9#antecedant> ;
    <http://www.w3.org/2000/10/swap/log/consequent> <https://www.w3.org/TR/rdf11-mt/rdfs9#consequent> .

<urn:dydra:n3Rules>
    rdf:_1 <urn:dydra:entailment:rdfs9> ;
    a rdf:Bag .

<urn:dydra:spTexts>
    <http://spinrdf.org/spin#nextRuleProperty> <urn:dydra:n3Rules> ;
    rdf:_1 <urn:dydra:entailment:rdfs7> ;
    a rdf:Bag .

<urn:dydra:spinRules>
    <http://spinrdf.org/spin#nextRuleProperty> <urn:dydra:spTexts> ;
    rdf:_1 <urn:dydra:entailment:rdfs2> ;
    rdf:_2 <urn:dydra:entailment:rdfs3> ;
    a rdf:Bag .

[]
    a _:w5eo568dz00cp5tv, [
        <http://www.w3.org/2000/01/rdf-schema#subClassOf> _:w5eo568dz00cp5tv
    ] .
EOF

# set up the data
curl_graph_store_update -X PUT   -w "%{http_code}\n" -o /dev/null \
     -H "Content-Type: application/n-triples" \
     --repository "mem-rdf-write"  <<EOF \
   | test_put_success
<http://example.org/subject> <http://example.org/predicate> <http://example.org/object> .
<http://example.org/predicate> <http://www.w3.org/2000/01/rdf-schema#domain> <http://example.org/class> .
EOF

# exercise the rules
curl_sparql_request --repository "mem-rdf-write" -H "libraryPath: openrdf-sesame/inference" <<EOF \
 | jq '.results.bindings[] | .[].value' | fgrep -q "http://example.org/class"
select * where {?s a ?class}
EOF
