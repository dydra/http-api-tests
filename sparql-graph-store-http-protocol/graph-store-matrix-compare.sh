#!/bin/bash -e

if [ "${GRAPH_STORE_PATCH_LEGACY}" = "true" ]; then
# rdfcache/dydrad:
base_txt=graph-store-matrix_rdfcache.txt
base_csv=graph-store-matrix_rdfcache.csv
else
# rlmdb:
base_txt=graph-store-matrix.txt
base_csv=graph-store-matrix.csv
fi

echo "Creating response matrix for sparql graph store http protocol..." > ${ECHO_OUTPUT}
bash ./graph-store-matrix.no_sh 2> "${base_csv}.tmp" |tee "${base_txt}.tmp" > ${ECHO_OUTPUT}

echo "Comparing created response matrix for sparql graph store http protocol..." > ${ECHO_OUTPUT}
# remove random parts of URN:UUIDs
sed 's/<urn:uuid:[0-9A-Z-]*>/<urn:uuid>/g' < "${base_txt}" > "${base_txt}_nouuid"
sed 's/<urn:uuid:[0-9A-Z-]*>/<urn:uuid>/g' < "${base_txt}.tmp" > "${base_txt}.tmp_nouuid"
# compare
diff -q "${base_csv}" "${base_csv}.tmp"
diff -q "${base_txt}_nouuid" "${base_txt}.tmp_nouuid"

# cleanup
echo "Deleting temp files: ${base_csv}.tmp ${base_txt}.tmp ${base_txt}.tmp_nouuid ${base_txt}_nouuid" > ${ECHO_OUTPUT}
rm "${base_csv}.tmp"
rm "${base_txt}.tmp"
rm "${base_txt}.tmp_nouuid"
rm "${base_txt}_nouuid"
