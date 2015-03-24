#! /bin/bash

# test sort order for ascending/descending options for commensurable types
# this exercises the path which interns the values and sorts the internal identifiers

curl_sparql_request <<EOF  \
 | jq '.results.bindings[] | .ordinal.value' | tr '\n' '.' | fgrep -q '"1"."2"."3"' 
select ?ordinal ?value
where {
  values (?ordinal ?value) {
    ( 2 2 )
    ( 3 3 )
    ( 1 1 )
  }
}
order by ?value
EOF


curl_sparql_request <<EOF  \
 | jq '.results.bindings[] | .ordinal.value' | tr '\n' '.' | fgrep -q '"3"."2"."1"' 
select ?ordinal ?value
where {
  values (?ordinal ?value) {
    ( 2 2 )
    ( 3 3 )
    ( 1 1 )
  }
}
order by desc(?value)
EOF

curl_sparql_request <<EOF  \
 | jq '.results.bindings[] | .ordinal.value' | tr '\n' '.' | fgrep -q '"1"."2"."3"' 
select ?ordinal ?value
where {
  values (?ordinal ?value) {
    ( 2 2.0 )
    ( 3 3.0 )
    ( 1 1.0 )
  }
}
order by ?value
EOF


curl_sparql_request <<EOF  \
 | jq '.results.bindings[] | .ordinal.value' | tr '\n' '.' | fgrep -q '"3"."2"."1"' 
select ?ordinal ?value
where {
  values (?ordinal ?value) {
    ( 2 2.0 )
    ( 3 3.0 )
    ( 1 1.0 )
  }
}
order by desc(?value)
EOF


curl_sparql_request <<EOF  \
 | jq '.results.bindings[] | .ordinal.value' | tr '\n' '.' | fgrep -q '"1"."2"' 
select ?ordinal ?value
where {
  values (?ordinal ?value) {
    ( 1 false )
    ( 2 true )
  }
}
order by ?value
EOF


curl_sparql_request <<EOF  \
 | jq '.results.bindings[] | .ordinal.value' | tr '\n' '.' | fgrep -q '"2"."1"' 
select ?ordinal ?value
where {
  values (?ordinal ?value) {
    ( 1 false )
    ( 2 true )
  }
}
order by desc(?value)
EOF


curl_sparql_request <<EOF  \
 | jq '.results.bindings[] | .ordinal.value' | tr '\n' '.' | fgrep -q '"1"."2"."3"' 
select ?ordinal ?value
where {
  values (?ordinal ?value) {
    ( 1 'aaaa'@en )
    ( 3 'cccc'@en )
    ( 2 'bbbb'@en )
  }
}
order by ?value
EOF


curl_sparql_request <<EOF  \
 | jq '.results.bindings[] | .ordinal.value' | tr '\n' '.' | fgrep -q '"3"."2"."1"' 
select ?ordinal ?value
where {
  values (?ordinal ?value) {
    ( 1 'aaaa'@en )
    ( 3 'cccc'@en )
    ( 2 'bbbb'@en )
  }
}
order by desc(?value)
EOF


curl_sparql_request <<EOF  \
 | jq '.results.bindings[] | .ordinal.value' | tr '\n' '.' | fgrep -q '"1"."2"."3"' 
select ?ordinal ?value
where {
  values (?ordinal ?value) {
    ( 1 'aaaa' )
    ( 3 'cccc' )
    ( 2 'bbbb' )
  }
}
order by ?value
EOF


curl_sparql_request <<EOF  \
 | jq '.results.bindings[] | .ordinal.value' | tr '\n' '.' | fgrep -q '"3"."2"."1"' 
select ?ordinal ?value
where {
  values (?ordinal ?value) {
    ( 1 'aaaa' )
    ( 3 'cccc' )
    ( 2 'bbbb' )
  }
}
order by desc(?value)
EOF


curl_sparql_request <<EOF  \
 | jq '.results.bindings[] | .ordinal.value' | tr '\n' '.' | fgrep -q '"1"."2"."3"' 
select ?ordinal ?value
where {
  values (?ordinal ?value) {
    ( 1 <http://example.org/aaaa> )
    ( 3 <http://example.org/cccc> )
    ( 2 <http://example.org/bbbb> )
  }
}
order by ?value
EOF


curl_sparql_request <<EOF  \
 | jq '.results.bindings[] | .ordinal.value' | tr '\n' '.' | fgrep -q '"3"."2"."1"' 
select ?ordinal ?value
where {
  values (?ordinal ?value) {
    ( 1 <http://example.org/aaaa> )
    ( 3 <http://example.org/cccc> )
    ( 2 <http://example.org/bbbb> )
  }
}
order by desc(?value)
EOF


curl_sparql_request <<EOF  \
 | jq '.results.bindings[] | .ordinal.value' | tr '\n' '.' | fgrep -q '"1"."2"."3"' 
select ?ordinal ?value
where {
  values (?ordinal ?value) {
    ( 1 '-P1Y2M'^^<http://www.w3.org/2001/XMLSchema#yearMonthDuration> )
    ( 3 'P1Y2M'^^<http://www.w3.org/2001/XMLSchema#yearMonthDuration> )
    ( 2 'P1Y1M'^^<http://www.w3.org/2001/XMLSchema#yearMonthDuration> )
  }
}
order by ?value
EOF


curl_sparql_request <<EOF  \
 | jq '.results.bindings[] | .ordinal.value' | tr '\n' '.' | fgrep -q '"3"."2"."1"' 
select ?ordinal ?value
where {
  values (?ordinal ?value) {
    ( 1 '-P1Y2M'^^<http://www.w3.org/2001/XMLSchema#yearMonthDuration> )
    ( 3 'P1Y2M'^^<http://www.w3.org/2001/XMLSchema#yearMonthDuration> )
    ( 2 'P1Y1M'^^<http://www.w3.org/2001/XMLSchema#yearMonthDuration> )
  }
}
order by desc(?value)
EOF


curl_sparql_request <<EOF  \
 | jq '.results.bindings[] | .ordinal.value' | tr '\n' '.' | fgrep -q '"1"."2"."3"' 
select ?ordinal ?value
where {
  values (?ordinal ?value) {
    ( 1 '-P1DT2H'^^<http://www.w3.org/2001/XMLSchema#dayTimeDuration> )
    ( 3 'P1DT2H'^^<http://www.w3.org/2001/XMLSchema#dayTimeDuration> )
    ( 2 'P1DT1H'^^<http://www.w3.org/2001/XMLSchema#dayTimeDuration> )
  }
}
order by ?value
EOF


curl_sparql_request <<EOF  \
 | jq '.results.bindings[] | .ordinal.value' | tr '\n' '.' | fgrep -q '"3"."2"."1"' 
select ?ordinal ?value
where {
  values (?ordinal ?value) {
    ( 1 '-P1DT2H'^^<http://www.w3.org/2001/XMLSchema#dayTimeDuration> )
    ( 3 'P1DT2H'^^<http://www.w3.org/2001/XMLSchema#dayTimeDuration> )
    ( 2 'P1DT1H'^^<http://www.w3.org/2001/XMLSchema#dayTimeDuration> )
  }
}
order by desc(?value)
EOF


curl_sparql_request <<EOF  \
 | jq '.results.bindings[] | .ordinal.value' | tr '\n' '.' | fgrep -q '"1"."2"."3"' 
select ?ordinal ?value
where {
  values (?ordinal ?value) {
    ( 1 '-2014-01-02T10:11:12Z'^^<http://www.w3.org/2001/XMLSchema#dateTime> )
    ( 3 '2014-01-02T10:11:12Z'^^<http://www.w3.org/2001/XMLSchema#dateTime> )
    ( 2 '2013-01-02T10:11:12Z'^^<http://www.w3.org/2001/XMLSchema#dateTime> )
  }
}
order by ?value
EOF


curl_sparql_request <<EOF  \
 | jq '.results.bindings[] | .ordinal.value' | tr '\n' '.' | fgrep -q '"3"."2"."1"' 
select ?ordinal ?value
where {
  values (?ordinal ?value) {
    ( 1 '-2014-01-02T10:11:12Z'^^<http://www.w3.org/2001/XMLSchema#dateTime> )
    ( 3 '2014-01-02T10:11:12Z'^^<http://www.w3.org/2001/XMLSchema#dateTime> )
    ( 2 '2013-01-02T10:11:12Z'^^<http://www.w3.org/2001/XMLSchema#dateTime> )
  }
}
order by desc(?value)
EOF


curl_sparql_request <<EOF  \
 | jq '.results.bindings[] | .ordinal.value' | tr '\n' '.' | fgrep -q '"1"."2"."3"' 
select ?ordinal ?value
where {
  values (?ordinal ?value) {
    ( 1 '-2014-01-01'^^<http://www.w3.org/2001/XMLSchema#date> )
    ( 3 '2014-01-01'^^<http://www.w3.org/2001/XMLSchema#date> )
    ( 2 '2013-01-01'^^<http://www.w3.org/2001/XMLSchema#date> )
  }
}
order by ?value
EOF


curl_sparql_request <<EOF  \
 | jq '.results.bindings[] | .ordinal.value' | tr '\n' '.' | fgrep -q '"3"."2"."1"' 
select ?ordinal ?value
where {
  values (?ordinal ?value) {
    ( 1 '-2014-01-01'^^<http://www.w3.org/2001/XMLSchema#date> )
    ( 3 '2014-01-01'^^<http://www.w3.org/2001/XMLSchema#date> )
    ( 2 '2013-01-01'^^<http://www.w3.org/2001/XMLSchema#date> )
  }
}
order by desc(?value)
EOF


curl_sparql_request <<EOF  \
 | jq '.results.bindings[] | .ordinal.value' | tr '\n' '.' | fgrep -q '"1"."2"."3"' 
select ?ordinal ?value
where {
  values (?ordinal ?value) {
    ( 1 '10:11:12'^^<http://www.w3.org/2001/XMLSchema#time> )
    ( 3 '12:11:12'^^<http://www.w3.org/2001/XMLSchema#time> )
    ( 2 '11:11:12'^^<http://www.w3.org/2001/XMLSchema#time> )
  }
}
order by ?value
EOF


curl_sparql_request <<EOF  \
 | jq '.results.bindings[] | .ordinal.value' | tr '\n' '.' | fgrep -q '"3"."2"."1"' 
select ?ordinal ?value
where {
  values (?ordinal ?value) {
    ( 1 '10:11:12'^^<http://www.w3.org/2001/XMLSchema#time> )
    ( 3 '12:11:12'^^<http://www.w3.org/2001/XMLSchema#time> )
    ( 2 '11:11:12'^^<http://www.w3.org/2001/XMLSchema#time> )
  }
}
order by desc(?value)
EOF


curl_sparql_request <<EOF  \
 | jq '.results.bindings[] | .ordinal.value' | tr '\n' '.' | fgrep -q '"1"."2"."3"' 
select ?ordinal ?value
where {
  values (?ordinal ?value) {
    ( 1 '2011'^^<http://www.w3.org/2001/XMLSchema#gYear> )
    ( 3 '2013'^^<http://www.w3.org/2001/XMLSchema#gYear> )
    ( 2 '2012'^^<http://www.w3.org/2001/XMLSchema#gYear> )
  }
}
order by ?value
EOF


curl_sparql_request <<EOF  \
 | jq '.results.bindings[] | .ordinal.value' | tr '\n' '.' | fgrep -q '"3"."2"."1"' 
select ?ordinal ?value
where {
  values (?ordinal ?value) {
    ( 1 '2011'^^<http://www.w3.org/2001/XMLSchema#gYear> )
    ( 3 '2013'^^<http://www.w3.org/2001/XMLSchema#gYear> )
    ( 2 '2012'^^<http://www.w3.org/2001/XMLSchema#gYear> )
  }
}
order by desc(?value)
EOF


