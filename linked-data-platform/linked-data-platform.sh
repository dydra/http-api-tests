#! /bin/bash

# test basic container with various content forms - container, rdf, non-rdf

export LDP_HOST="${STORE_HOST}"
export LDP_ACCOUNT="${STORE_ACCOUNT}"
export LDP_REPOSITORY="${LDP_ACCOUNT}/ldp"
export LDP_TOKEN=`cat ~/.dydra/${LDP_HOST}.${LDP_ACCOUNT}.token`

function curl_ldp_get() {
  ${CURL} -f -s -k \
    -H "Accept: application/n-quads" \
    "https://${LDP_HOST}/${LDP_REPOSITORY}/service"
}

# clear it
set +e  # 404 if empty
rm -f tmp?.*
bash ./DELETE-ldp
set -e
curl_ldp_get #| wc -c | egrep -s " 0$"

# import initial container
bash ./PUT-root-container

# and content
bash ./POST-foaf
bash ./POST-fotos
bash ./POST-fotos-inline
bash ./POST-fotos-link
bash ./POST-text
bash ./POST-csv

# test foaf
echo -n "" > tmp0.nt
${CURL} -s -o tmp0.nt -k -H "Accept: application/n-triples" https://${LDP_HOST}/${LDP_REPOSITORY}/ldp?resource=http://example.org/alice/foaf
fgrep -q "FOAF file" tmp0.nt
wc -l tmp0.nt | fgrep -q " 6 tmp0.nt"
fgrep -c '#type' tmp0.nt | egrep -q '^3$'
fgrep -c '#me' tmp0.nt | egrep -q '^3$'

# test the inline image
echo -n "" > tmp1.png
${CURL} -s -o tmp1.png -k https://${LDP_HOST}/${LDP_REPOSITORY}/ldp/ldp?resource=http://example.org/alice/photos/logo1
file tmp1.png | fgrep -q "PNG image data"
cmp -s tmp1.png dydra-logo-24pt.png

# test the linked image
echo -n "" > tmp2.png
${CURL} -s -L -o tmp2.png -k https://${LDP_HOST}/${LDP_REPOSITORY}/ldp/ldp?resource=http://example.org/alice/photos/logo2
file tmp2.png | fgrep -q "PNG image data"
${CURL} -s https://dydra.com/logo-98x98.png | cmp - tmp2.png

# test text
echo -n "" > tmp3.txt
${CURL} -s -L -o tmp3.txt -k https://${LDP_HOST}/${LDP_REPOSITORY}/ldp/ldp?resource=http://example.org/alice/sometext
file tmp3.txt | fgrep -q "ASCII"
fgrep -q 'history' tmp3.txt

# test csv
echo -n "" > tmp4.csv
${CURL} -s -L -o tmp4.csv -k https://${LDP_HOST}/${LDP_REPOSITORY}/ldp/ldp?resource=http://example.org/alice/csvdata1
file tmp4.csv | fgrep -q "ASCII text"
wc -l tmp4.csv | fgrep -q ' 3 tmp4.csv'
fgrep -q "name, size" tmp4.csv

${CURL} -f -s -k -H "Accept: application/n-quads" \
    "https://${LDP_HOST}/${LDP_REPOSITORY}/service" > ldp.nq
bash ./DELETE-root-container

# repository should now be empty
${CURL} -f -s -k -H "Accept: application/n-quads" \
   "https://${LDP_HOST}/${LDP_REPOSITORY}/service" \
 | wc -c | egrep -q ' 0$'

# if all succeeded
rm tmp?.*

