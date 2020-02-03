#! /bin/bash

ACCOUNT="jhacker"
REPOSITORY="system"
HOST="de8.dydra.com"
MIME="application/sparql-query"
TOKEN=""

while [[ "$#" > 0 ]] ; do
  case "$1" in
    --account) ACCOUNT="${2}"; shift 2;;
    --host) HOST="${2}"; shift 2;;
    --mime) MIME="${2}"; shift 2;;
    --repository) REPOSITORY="${2}"; shift 2;;
    *) "echo ${0} --account --host --repository --token"; exit 1;;
  esac
done
if [[ "" == "$TOKEN" ]]
then
  TOKEN=`cat ~/.dydra/token@${HOST}`
fi

echo   "https://${HOST}/${ACCOUNT}/${REPOSITORY}/sparql" 

curl --silent -k --ipv4 -X POST --data-binary @- \
  --user ":${TOKEN}" \
  -H "Accept: application/n-triples" \
  -H "Content-Type: application/sparql-query" \
  "https://${HOST}/${ACCOUNT}/${REPOSITORY}/sparql" <<EOF \
    | sed -e 's/<//g'     | sed -e 's/>//g'  | sed -e 's/http:/https:/g' \
    | sed -e "s:/dydra.com/:/${HOST}/:g" \
    | while read repo view name; do echo; echo $view; curl -L --silent -k --ipv4 -X GET -L -H "Accept: ${MIME}" --user ":${TOKEN}" $view; echo ""; done
construct {
  ?repository ?view ?name
}
where {
  graph  ?repository {
    ?view a <urn:dydra:View> .
    ?view <http://xmlns.com/foaf/0.1/name> ?name
  }
}
EOF
