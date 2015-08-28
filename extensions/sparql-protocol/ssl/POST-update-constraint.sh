#! /bin/bash

# a test of update notification
# acts as a loopback by specifying the response body as the notification destination
#
# the request itself includes as arguments
#  query : the query text inline as sparql or an iri which designates the script by reference
#  script : either an inline script as turtle or an iri which designates the script by reference
#
# where the request is application/x-www-form-urlencoded the types of form elements is
# fixed by role. where multipart/form-data is used, each element can specify a content type.


curl_sparql_request \
   -H "Accept: application/sparql-results+json" \
   -H "Content-Type: application/x-www-form-urlencoded" \
   "--data-urlencode" "sparql@/dev/fd/3" "query@/dev/fd/4" \
   3<<EOF3 4<<EOF4 \
 | jq '.results.bindings[] | .[].value' | fgrep -q "BSS84"
INSERT DATA {
 GRAPH <http://example.org/uri1/notification> {
  <http://example.org/uri1/one> <foaf:name> "object-for-constraint" .
  <http://example.org/uri1/one> rdf:type <http://example.org/object-for-constraint> .
 }
}
EOF3
[ a :Update ;
  :name 'Update under Constraint';
  :steps  ( [ a :Decode ;
              :location _:sparql ;
              :media-type "application/sparql-query" ]
            [ a :Bind ;
              :dataset [ a :Dataset ;
                          :location _:requestRepository ] ]
            [ a :Project ]
            [ a :Constrain ;
              :dataset [ a :Dataset ;
                         :location _:requestRepository ; ] ;
              :steps ( [ a :Decode ;
                          :location <http://exmaple.org/notification.rq> ;
                          :media-type <http://www.iana.org/assignments/media-types/application/sparql-query>  ]
                        [ a :Bind ;
                         :dataset [ a :Dataset ;
                                     :location _:requestRepository ];
                                     :method [ a :GraphMatcher ] ]
                        [ a :Project ]
                        # no encoding,
                        # the result field is the predicate result for the conditional
                        # any violations are present as the results
                      ) ]
            [ a :Conditional ;
              # any solutions indicate failure,
              # abort the query, return the constraint results
              :consequent ( [ a :Abort ]
                            [ a :Encode ;
                              :location _:responseContent ;
                              :media-type <http://www.iana.org/assignments/media-types/application/sparql-results+json>  ] 
                            ) ;
              # no solution indicates the constraints were satisfied
              :alternative ( [ a :Commit  ]
                             [ a :Encode ;
                               :location _:responseContent ;
                               :media-type _:responseContentType  ] 
                           ) ]
            
            )
] .
EOF4
