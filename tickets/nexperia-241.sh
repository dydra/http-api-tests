#! /bin/bash
#
# test that regex works on strings with language tags

curl_sparql_request \
     --repository "${STORE_REPOSITORY}" \
     -H 'Accept: application/sparql-results+json' <<EOF \
   | tee $ECHO_OUTPUT \
   | fgrep -c label | fgrep -q '4'
select *
where {
  values ?label {
    'Automotive ESD Ethernet no language'
    'Automotive ESD Ethernet English'@en
    'Automotive ESD Ethernet US English'@en-us
  }
  filter regex(?label, 'ether', 'i')
}
EOF



