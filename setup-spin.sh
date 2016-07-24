#! /bin/bash

# test library item references


# make sure the repositories exist

curl -v -f -s -S -X POST \
     -H "Content-Type: application/json"  --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories?auth_token=${STORE_TOKEN} << EOF
{"repository" : {"name" : "spin-data" } }
EOF

curl -v -f -s -S -X POST \
     -H "Content-Type: application/json"  --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories?auth_token=${STORE_TOKEN} << EOF
{"repository" : {"name" : "spin-library" } }
EOF


# set the library search path for the data repository

curl -f -s -S -X POST \
     -H "Content-Type: application/json"  --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/repositories/spin-data?auth_token=${STORE_TOKEN} << EOF
{"library-path": "<urn:dydra:all> <http://example.org/spin1> <http://example.org/spin2>"}
EOF


# load the data repository
# see http://topbraid.org/examples/

$CURL -w "%{http_code}\n" -f -s -S -X PUT \
     -H "Content-Type: application/rdf+xml" \
     --data-binary @kennedys.rdf \
     ${STORE_URL}/${STORE_ACCOUNT}/spin-data?auth_token=${STORE_TOKEN} \
  | egrep -q "$STATUS_PUT_SUCCESS"


# load the library repository
$CURL -w "%{http_code}\n" -f -s -S -X PUT \
     -H "Content-Type: text/turtle" \
     --data-binary @- \
     ${STORE_URL}/${STORE_ACCOUNT}/spin-data?auth_token=${STORE_TOKEN} <<EOF \
  | egrep -q "$STATUS_PUT_SUCCESS"
<http://topbraid.org/schema.ui#ChildrenOverview>
      a       spin:SelectTemplate ;
      rdfs:comment "Adapted from A (demo) SELECT template displaying some information about the children of a given schema:Person."^^xsd:string ;
      rdfs:label "Children overview"^^xsd:string ;
      rdfs:subClassOf spin:SelectTemplates ;
      spin:constraint
              [ a       spl:Argument ;
                rdfs:comment "The schema:Person to get the children of."^^xsd:string ;
                spl:predicate arg:parent ;
                spl:valueType schema:Person
              ] ;
      spin:body
              [ a       sp:Select ;
                sp:text """
                    SELECT ?childName ?birthDate
                    WHERE {
                        ?child schema:parent ?parent .
                        ?child rdfs:label ?childName .
                        OPTIONAL { 
                            ?child schema:birthDate ?birthDate .
                        } .
                    }
                    """
              ] ;EOF

