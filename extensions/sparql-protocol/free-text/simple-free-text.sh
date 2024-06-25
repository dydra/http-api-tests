#! /bin/bash
set -e

## nb. these tests will fail while the implementation is in flux

# exercise a string to term identifier index
# there are two text index forms
# - a simple text index for just one string identifier
# - a compound text index for materialized view parameters
#
# this script tests an index of the first form, the simple text index.
# the intent of the simple text index is to provide the equivalent
# of a filter, but without iterative over supplied terms.
# instead of passing a sequence of solutions through a filter, as in
#
#    select $string where { ?s ?p $string . filter(isMatchingString($string)) }
#
# (nb, the isMatchingString symbolizes the test, it does not actually exist.)
#
# these tests work with the test/foaf repository to exercise both index forms:
#
# for the simple index
# - replace the content of the "test/test" repository with text
#   for this use the label statements from the stw dataset (https://zbw.eu/stw/version/latest/download/about)
# - execute a request which uses the text index.
#   this will create it
# - drop the index

echo "${0} import text dataset" >  ${ECHO_OUTPUT}

curl_graph_store_update -X PUT \
  -H "Content-Type: application/n-quads" \
  -H "Accept: application/n-quads" \
  --account "test" \
  --repository "test" \
  --data-binary @stw-label.nt

echo "${0} run query" >  ${ECHO_OUTPUT}

curl_sparql_request -X POST \
    -H "Content-Type: application/sparql-query" \
    -H "Accept: application/sparql-results+json" \
    --account "test" \
    --repository "test" \
    --data-binary @- <<EOF \
  | fgrep -c Vorsorge | fgrep -q 6
SELECT ?lbl
WHERE  { ( ?lbl ) <http://jena.hpl.hp.com/ARQ/property#textMatch> ('Vorsorg:*') . }
EOF


echo "${0} drop text index" >  ${ECHO_OUTPUT}

${CURL} -X DELETE "${STORE_URL}/system/accounts/test/repositories/test/text-index" \
  -H "Authorization: Bearer ${STORE_TOKEN}" \
  -H "Accept: application/json" \
  | fgrep -s -q DELETE


echo "${0} complete" >  ${ECHO_OUTPUT}

