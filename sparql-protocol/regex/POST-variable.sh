#! /bin/bash

# test that variable regex patterns are properly cached
curl_sparql_request  \
     --repository "collation" <<EOF \
  | tee $ECHO_OUTPUT | wc | fgrep -s '3'
select  ?pattern ?value
where {
  values (?key ?pattern) { ('k1' 'A+' )  ('k2' 'B+' )  ('k3' 'C+' ) }
  values (?key ?value) {
    ('k1' 'AAAA' ) ('k1' '111' ) ('k1' 'B' ) ('k1' 'C' )
    ('k2' 'A' ) ('k2' 'B' ) ('k2' 'BB' ) ('k2' 'C' )
    ('k3' 'B' ) ('k3' 'A' )
  }
  filter (regex(?value, ?pattern))
}
EOF

cat >/dev/null <<EOF
(test-sparql "
select  ?pattern ?value
where {
  values (?key ?pattern) { ('k1' 'A+' )  ('k2' 'B+' )  ('k3' 'C+' ) }
  values (?key ?value) {
    ('k1' 'AAAA' ) ('k1' '111' ) ('k1' 'B' ) ('k1' 'C' )
    ('k2' 'A' ) ('k2' 'B' ) ('k2' 'BB' ) ('k2' 'C' )
    ('k3' 'B' ) ('k3' 'A' )
  }
  filter (regex(?value, ?pattern))
}
" 
:repository-id "system/null")
EOF
