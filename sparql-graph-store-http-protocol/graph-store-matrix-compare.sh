#!/bin/bash -e
echo "Creating response matrix for sparql graph store http protocol..." > ${ECHO_OUTPUT}
bash ./graph-store-matrix.no_sh 2>graph-store-matrix.csv.tmp |tee graph-store-matrix.txt.tmp > ${ECHO_OUTPUT}

echo "Comparing created response matrix for sparql graph store http protocol..." > ${ECHO_OUTPUT}
# remove random parts of URN:UUIDs
sed 's/<urn:uuid:[0-9A-Z-]*>/<urn:uuid>/g' < graph-store-matrix.txt > graph-store-matrix.txt_nouuid
sed 's/<urn:uuid:[0-9A-Z-]*>/<urn:uuid>/g' < graph-store-matrix.txt.tmp > graph-store-matrix.txt.tmp_nouuid
# compare
diff -q graph-store-matrix.csv graph-store-matrix.csv.tmp
diff -q graph-store-matrix.txt_nouuid graph-store-matrix.txt.tmp_nouuid

# cleanup
rm graph-store-matrix.csv.tmp
rm graph-store-matrix.txt.tmp
rm graph-store-matrix.txt.tmp_nouuid
rm graph-store-matrix.txt_nouuid
