#! /bin/bash
#
# validate specific substring combinations

curl_sparql_request <<EOF  \
 | tee $ECHO_OUTPUT | tr '\n' ' ' | fgrep '"abcdefg"' | fgrep '"defg"' | fgrep -q '"d"' 
select ?s1 ?s2 ?s3
where {
  bind("abcdefg" as ?s1)
  bind(substr(?s1, 4) as ?s2)
  bind(substr(?s1, 4, 1) as ?s3)
}
EOF
