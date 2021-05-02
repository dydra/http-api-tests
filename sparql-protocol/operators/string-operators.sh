#! /bin/bash

# test string operators

# STRSTARTS, STRENDS, CONTAINS, STRBEFORE and STRAFTER 

curl_sparql_request <<EOF  \
 | tee $ECHO_OUTPUT | fgrep -q "true" 
select ?shouldBeTrue
where {
  bind((strStarts("foobar", "foo")
        && strStarts("foobar"@en, "foo"@en)
        && strStarts("foobar"^^xsd:string, "foo"^^xsd:string)
        && strStarts("foobar"^^xsd:string, "foo")
        && strStarts("foobar", "foo"^^xsd:string)
        && strStarts("foobar"@en, "foo")
        && strStarts("foobar"@en, "foo"^^xsd:string)) as ?shouldBeTrue)
}
EOF

curl_sparql_request <<EOF  \
 | tee $ECHO_OUTPUT | fgrep -q "true" 
select ?shouldBeTrue
where {
  bind((strEnds("foobar", "bar")
        && strEnds("foobar"@en, "bar"@en)
        && strEnds("foobar"^^xsd:string, "bar"^^xsd:string)
        && strEnds("foobar"^^xsd:string, "bar")
        && strEnds("foobar", "bar"^^xsd:string)
        && strEnds("foobar"@en, "bar")
        && strEnds("foobar"@en, "bar"^^xsd:string)) as ?shouldBeTrue)
}
EOF

curl_sparql_request <<EOF  \
 | tee $ECHO_OUTPUT | fgrep -q "true" 
select ?shouldBeTrue
where {
  bind((contains("foobar", "bar")
        && contains("foobar"@en, "foo"@en)
        && contains("foobar"^^xsd:string, "bar"^^xsd:string)
        && contains("foobar"^^xsd:string, "foo")
        && contains("foobar", "bar"^^xsd:string)
        && contains("foobar"@en, "foo")
        && contains("foobar"@en, "bar"^^xsd:string)) as ?shouldBeTrue)
}
EOF