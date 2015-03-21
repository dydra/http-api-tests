#! /bin/bash

# exercise combination of arithmetic and comparison operators over temporal data
# this test subtracts a duration from an xsd:dateTime literal bound to ?now variable and tests the result against other xsd:dateTime literals using the eq, lt and gt operators
# the repository is initialized with data where:
# - the value of ex:duration is the duration to be subtracted from ?now
# - the values of ex:dateEq, ex:dateLt and ex:dateGt are xsd:dateTime values that are used for the respective eq, lt and gt comparisons
# - these values are such that the result of the comparison is expected to be true
#
# nb. wrt the names for temporal datatypes
# one must exercise care when specifying the type for temporal values in the store.
# although the XPATH semantics associated with the terms in the namespace "http://www.w3.org/2001/XMLSchema-datatypes"
# is defined to be the same as that of the respective terms in the namespace "http://www.w3.org/2001/XMLSchema",
# with respect to RDF, these terms are not the same. that is, if compared, they are neither identical nor equal.
# within the sparql processor, the XPath semantic equivalence applies with respect to arithmetic operations,
# which range over both XMLSchema-datatypes and XMLSchema terms, but logical operations revert in this case to
# RDF semantics, under which terms from the different namespaces are incommensurable.
#
# thus the namespace specified in the import must be "http://www.w3.org/2001/XMLSchema#"

set_sparql_url "${STORE_ACCOUNT}" "${STORE_REPOSITORY}-write"
set_graph_store_url "${STORE_ACCOUNT}" "${STORE_REPOSITORY}-write"

curl_graph_store_put default <<EOF \
    | egrep -q "$STATUS_PUT_SUCCESS"
@prefix ex: <http://example.com/> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

_:a ex:dateEq "2013-12-31T00:00:00Z"^^xsd:dateTime ;
  ex:dateLt "2013-12-31T00:00:01Z"^^xsd:dateTime ;
  ex:dateGt "2013-12-30T23:59:59Z"^^xsd:dateTime ;
  ex:duration "PT24H"^^xsd:dayTimeDuration .

_:b ex:dateEq "2013-12-02T00:00:00Z"^^xsd:dateTime ;
  ex:dateLt "2013-12-03T00:00:00Z"^^xsd:dateTime ;
  ex:dateGt "2013-12-01T00:00:00Z"^^xsd:dateTime ;
  ex:duration "P30D"^^xsd:dayTimeDuration .

_:c ex:dateEq "2013-10-01T00:00:00Z"^^xsd:dateTime ;
  ex:dateLt "2013-11-01T00:00:00Z"^^xsd:dateTime ;
  ex:dateGt "2013-09-01T00:00:00Z"^^xsd:dateTime ;
  ex:duration "P3M"^^xsd:yearMonthDuration .

_:d ex:dateEq "2012-07-01T00:00:00Z"^^xsd:dateTime ;
  ex:dateLt "2013-07-01T00:00:00Z"^^xsd:dateTime ;
  ex:dateGt "2011-07-01T00:00:00Z"^^xsd:dateTime ;
  ex:duration "P1Y6M"^^xsd:yearMonthDuration .
EOF


curl_sparql_request <<EOF \
  | jq '.results.bindings[] | .[].value' | fgrep 'true' | wc -l | fgrep -q '4'

prefix xsd: <http://www.w3.org/2001/XMLSchema-datatypes>
prefix ex: <http://example.com/>

select (((?date_offset = ?dateEq) &&
         (?date_offset < ?dateLt) &&
         (?date_offset > ?dateGt))
        as ?ok)
where {
  ?s ex:dateEq ?dateEq ;
    ex:dateLt ?dateLt ;
    ex:dateGt ?dateGt ;
    ex:duration ?duration .
  bind ('2014-01-01T00:00:00Z'^^xsd:dateTime as ?now)
  bind (?now - ?duration as ?date_offset)
}
EOF
