#!/usr/bin/env bash

# ---------------------------------------------------------------------------
#  service-administration integration tests (explicit flow)
# ---------------------------------------------------------------------------
#  Environment variables expected (http-api-tests framework):
#    STORE_HOST           – full host, e.g. dev.dydra.com
#    STORE_ACCOUNT        – account slug
#    STORE_REPOSITORY     – repository slug
#    STORE_AUTH_TOKEN     – bearer token
# ---------------------------------------------------------------------------

set -euo pipefail

# ------------------------------------------------------------
# Ensure INFO prefixes every line with the script name
# ------------------------------------------------------------

BLUE='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'
export INFO_OUTPUT=/dev/tty
INFO()  { echo -e "${BLUE}[INFO]${NC} $(basename "$0"): $*" > "$INFO_OUTPUT"; }
FAIL()  { echo -e "${RED}[FAIL]${NC} $(basename "$0"): $*" >&2; }


# ensure required env vars are set; do not rebind them
: "${STORE_HOST:?STORE_HOST env var not set}"
: "${STORE_ACCOUNT:?STORE_ACCOUNT env var not set}"
: "${STORE_REPOSITORY:?STORE_REPOSITORY env var not set}"
: "${STORE_TOKEN:?STORE_TOKEN env var not set}"
INFO "=== service-administration tests (repo: ${STORE_ACCOUNT}/${STORE_REPOSITORY}) ==="

ACCOUNT_CFG_EP="https://${STORE_HOST}/system/accounts/${STORE_ACCOUNT}/configuration"
REPO_CFG_EP="https://${STORE_HOST}/system/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/configuration"

# ---------------------------------------------------------------------------
# helper: ensure WANT json keys+values exist in HAVE json
# ---------------------------------------------------------------------------
json_contains() {
  local want="$1" have="$2"
  # Strip surrounding [ ] delimiters (if present) and whitespace from the fragment we
  # expect (WANT). Afterwards, use Node.js to parse the JSON structures and verify
  # that at least one object inside the response (HAVE) contains **all** key/value
  # pairs specified in the WANT fragment.  This allows the check to succeed even
  # when the response is an array with additional collaboration entries or when
  # property orders differ.
  node - <<'JS' "$want" "$have"
const wantRaw = process.argv[2];
const haveRaw = process.argv[3];

function stripBrackets(str) {
  return str;
  const t = str.trim(); return t;
//  return (t.startsWith('[') && t.endsWith(']')) ? t.slice(1, -1) : t;
}

let want;
let have;
try {
  console.warn("wantRaw", wantRaw);
  want = JSON.parse(stripBrackets(wantRaw));
  console.warn("want", want);
} catch (e) {
  console.error('Invalid HAVE JSON:', wantRaw);
  console.error('Invalid WANT JSON:', e.message);
  process.exit(1);
}
try {
  console.warn("haveRaw", haveRaw);
  have = JSON.parse(haveRaw);
  console.warn("have", have);
} catch (e) {
  console.error('Invalid HAVE JSON:', haveRaw);
  console.error('Invalid HAVE JSON:', e.message);
  process.exit(1);
}

function normalize(val) {
  return String(val).replace(/\s+/g, '');
}

function objectMatches(needle, hay) {
  return Object.entries(needle).every(([k, v]) =>
    k in hay && normalize(hay[k]) === normalize(v)
  );
}

let ok = false;
if (Array.isArray(have)) {
  const needles = Array.isArray(want) ? want : [want];
  ok = needles.every(n => have.some(h => objectMatches(n, h)));
} else {
  ok = objectMatches(Array.isArray(want) ? want[0] : want, have);
}

if (!ok) {
  console.error('Test fragment not found in response');
  console.error('WANT:', JSON.stringify(want, null, 2));
  console.error('HAVE:', JSON.stringify(have, null, 2));
  process.exit(1);
}
process.exit(0);
JS
}

# ---------------------------------------------------------------------------
# 1) Fetch initial configurations
# ---------------------------------------------------------------------------
INFO "Step 1: fetch initial configurations"
resp=$(curl_graph_store_get --url "$ACCOUNT_CFG_EP" \
        -H "Authorization: Bearer $STORE_TOKEN" \
        -H "Accept: application/json" \
        -w "\nstatuscode:%{http_code}\n")
echo initial account response: $resp > $INFO_OUTPUT
http=$(echo "$resp" | fgrep statuscode | sed -e's/^statuscode://')
orig_account_cfg=$(echo "$resp" | sed -e 's/^statuscode:.*//')
echo "$http" | test_ok step1.account || { echo "step1.account failed"; exit 1; }

resp=$(curl_graph_store_get --url "$REPO_CFG_EP" \
        -H "Authorization: Bearer $STORE_TOKEN" \
        -H "Accept: application/json" \
        -w "\nstatuscode:%{http_code}\n")
echo initial repeository response: $resp > $INFO_OUTPUT
http=$(echo "$resp" | fgrep statuscode | sed -e 's/^statuscode://')
orig_repo_cfg=$(echo "$resp" | sed -e 's/^statuscode:.*//')
echo "$http" | test_ok step1.repo || { echo "step1.repo failed"; exit 1; }

# echo "orig_repo_cfg: $orig_repo_cfg"

# ---------------------------------------------------------------------------
# 2) Update account configuration
# ---------------------------------------------------------------------------
INFO "Step 2: update account configuration"
new_account_cfg='{ "email":"meta@test.unexample", "fullName":"Meta Testing", "accessToken":"deadbeefcafebabie" }'

resp=$(curl_graph_store_post --url "$ACCOUNT_CFG_EP" \
        -H "Authorization: Bearer $STORE_TOKEN" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        --data "$new_account_cfg" \
        -w "\nstatuscode:%{http_code}\n")
http=$(echo "$resp" | fgrep statuscode | sed -e 's/^statuscode://')
echo "$http" | test_ok step2.post_account || { echo "step2.post_account failed"; exit 1; }

resp=$(curl_graph_store_get --url "$ACCOUNT_CFG_EP" \
        -H "Authorization: Bearer $STORE_TOKEN" \
        -H "Accept: application/json" \
        -w "\nstatuscode:%{http_code}\n")
updated_account_cfg=$(echo "$resp" | sed -e 's/^statuscode:.*//')
if json_contains "$new_account_cfg" "$updated_account_cfg"; then
  INFO "Step 2: update account configuration succeeded"
else
  FAIL "step2.verify_account failed"
  exit 1
fi

# ---------------------------------------------------------------------------
# 3) Restore original account configuration
# ---------------------------------------------------------------------------
INFO "Step 3: restore original account configuration"
resp=$(curl_graph_store_post --url "$ACCOUNT_CFG_EP" \
        -H "Authorization: Bearer $STORE_TOKEN" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        --data "$orig_account_cfg" \
        -w "\nstatuscode:%{http_code}\n")
http=$(echo "$resp" | fgrep statuscode | sed -e 's/^statuscode://')
echo "$http" | test_ok step3.restore_account || { echo "step3.restore_account failed"; exit 1; }

resp=$(curl_graph_store_get --url "$ACCOUNT_CFG_EP" \
        -H "Authorization: Bearer $STORE_TOKEN" \
        -H "Accept: application/json" \
        -w "\nstatuscode:%{http_code}\n")
restored_account_cfg=$(echo "$resp" | sed -e 's/^statuscode:.*//')
if json_contains "$orig_account_cfg" "$restored_account_cfg"; then
   INFO "Step 3: restore original account configuration succeeded"
else
  FAIL "step3.verify_account failed"
  exit 1
fi

# ---------------------------------------------------------------------------
# 4) Update repository configuration
# ---------------------------------------------------------------------------
INFO "Step 4: update repository configuration"
new_repo_cfg='{ "abstract":"Meta Repo", "description":"meta description", "privacySetting":"readByAuthenticatedUserOrIP", "prefixes":"PREFIX xx: <http://xx.org/ns#>\n", "permissible_ip_addresses":"127.0.0.1" }'

resp=$(curl_graph_store_post --url "$REPO_CFG_EP" \
        -H "Authorization: Bearer $STORE_TOKEN" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        --data "$new_repo_cfg" \
        -w "\nstatuscode:%{http_code}\n")
http=$(echo "$resp" | fgrep statuscode | sed -e 's/^statuscode://')
echo "$http" | test_ok step4.post_repo || { echo "step4.post_repo failed"; exit 1; }

resp=$(curl_graph_store_get --url "$REPO_CFG_EP" \
        -H "Authorization: Bearer $STORE_TOKEN" \
        -H "Accept: application/json" \
        -w "\nstatuscode:%{http_code}\n")
updated_repo_cfg=$(echo "$resp" | sed -e 's/^statuscode:.*//')
if json_contains "$new_repo_cfg" "$updated_repo_cfg"; then
  INFO "Step 4: update repository configuration succeeded"
else
  FAIL "step4.verify_repo failed"
  exit 1
fi

# ---------------------------------------------------------------------------
# 5) Restore original repository configuration
# ---------------------------------------------------------------------------
INFO "Step 5: restore original repository configuration"
resp=$(curl_graph_store_post --url "$REPO_CFG_EP" \
        -H "Authorization: Bearer $STORE_TOKEN" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        --data "$orig_repo_cfg" \
        -w "\nstatuscode:%{http_code}\n")
http=$(echo "$resp" | fgrep statuscode | sed -e 's/^statuscode://')
echo "$http" | test_ok step5.restore_repo || { echo "step5.restore_repo failed"; exit 1; }

resp=$(curl_graph_store_get --url "$REPO_CFG_EP" \
        -H "Authorization: Bearer $STORE_TOKEN" \
        -H "Accept: application/json" \
        -w "\nstatuscode:%{http_code}\n")
restored_repo_cfg=$(echo "$resp" | sed -e 's/^statuscode:.*//')
echo "restored: ${restored_repo_cfg}"
if json_contains "$orig_repo_cfg" "$restored_repo_cfg"; then
  INFO "Step 5: restore original repository configuration succeeded"
else
  FAIL "step5.verify_restore_repo failed"
  exit 1
fi

# ---------------------------------------------------------------------------
# 6) CRUD operations on repository collaborations
# ---------------------------------------------------------------------------
COLLAB_EP="https://${STORE_HOST}/system/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}/collaboration"
# ---------------------------------------------------------------------------
# SPARQL endpoint for the account's system repository (used to verify that
# collaboration metadata is propagated as ACL quads)
# ---------------------------------------------------------------------------
SYS_SPARQL_EP="https://${STORE_HOST}/${STORE_ACCOUNT}/system/sparql"
REPOSITORY_IRI="http://dydra.com/accounts/${STORE_ACCOUNT}/repositories/${STORE_REPOSITORY}"
SPARQL_COUNT_QUERY='select (count(*) as ?c) where { graph ?g { ?s <http://www.w3.org/ns/auth/acl#agent> ?agent . filter(contains(str(?agent), "jhacker")) } }'
SPARQL_ACCESS_QUERY="
select ?mode where {
  graph <${REPOSITORY_IRI}> {
    ?node <http://www.w3.org/ns/auth/acl#accessTo> <${REPOSITORY_IRI}> .
    ?node <http://www.w3.org/ns/auth/acl#agent> <http://dydra.com/users/jhacker> .
    ?node <http://www.w3.org/ns/auth/acl#mode> ?mode }
}"

# Helper: return the number of ACL triples referencing "jhacker" in the system repository
get_jhacker_acl_count() {
  curl -sS --url "$SYS_SPARQL_EP" \
       -H "Authorization: Bearer $STORE_TOKEN" \
       -H "Content-Type: application/sparql-query" \
       -H "Accept: application/sparql-results+json" \
       --data "$SPARQL_COUNT_QUERY" | tee /dev/tty |
    node -e "const a=require('fs').readFileSync(0,'utf8'); const j=JSON.parse(a); console.log(j.results.bindings[0] ? j.results.bindings[0].c.value : 0);"
}
get_jhacker_acl_modes() {
  curl -sS --url "$SYS_SPARQL_EP" \
       -H "Authorization: Bearer $STORE_TOKEN" \
       -H "Content-Type: application/sparql-query" \
       -H "Accept: application/json" \
       --data "${SPARQL_ACCESS_QUERY}" | tr '\n' ' '
}

INFO "Step 6a: fetch existing collaboration list"
resp=$(curl_graph_store_get --url "$COLLAB_EP" \
        -H "Authorization: Bearer $STORE_TOKEN" \
        -H "Accept: application/json" \
        -w "\nstatuscode:%{http_code}\n")
echo existing response: $resp > $INFO_OUTPUT
http=$(echo "$resp" | fgrep statuscode | sed -e 's/^statuscode://')
orig_collab=$(echo "$resp" | sed -e 's/^statuscode:.*//')
echo 
# --- create a collaboration --------------------------------------------------
new_collab='[{"account":"jhacker","read":true,"write":false}]'

INFO "Step 6b: create collaboration jhacker"
resp=$(curl_graph_store_post --url "$COLLAB_EP" \
        -H "Authorization: Bearer $STORE_TOKEN" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        --data "$new_collab" \
        -w "\nstatuscode:%{http_code}\n")
http=$(echo "$resp" | fgrep statuscode | sed -e 's/^statuscode://')
echo "$http" | test_ok step6.post_create || FAIL "create collaboration failed"

# verify creation
resp=$(curl_graph_store_get --url "$COLLAB_EP" -H "Authorization: Bearer $STORE_TOKEN" -H "Accept: application/json" -w "\nstatuscode:%{http_code}\n")
echo created response: $resp > $INFO_OUTPUT
current_collab=$(echo "$resp" | sed -e 's/^statuscode:.*//')
if json_contains "$new_collab" "$current_collab"; then
  # also verify that collaboration metadata was written to the system repository
  echo "mode query : ${SPARQL_ACCESS_QUERY}"
  modes_after_create=$(get_jhacker_acl_modes)
  echo created mode response: ${modes_after_create} > $INFO_OUTPUT
  if json_contains '[{"mode": "http://www.w3.org/ns/auth/acl#Read" }]' "${modes_after_create}"; then
    INFO "Step 6b metadata verification succeeded"
  else
    FAIL "Step 6b collaboration metadata not propagated to system repository"; exit 1
  fi
else
  FAIL "Step 6b collaboration create verification failed"; exit 1
fi

# --- update collaboration (give write=true) ----------------------------------
update_collab='[{"account":"jhacker","read":true,"write":true}]'

INFO "Step 6c: update collaboration jhacker (write=true)"
resp=$(curl_graph_store_post --url "$COLLAB_EP" \
      -H "Authorization: Bearer $STORE_TOKEN" \
      -H "Content-Type: application/json" \
      -H "Accept: application/json" \
      --data "$update_collab" -w "\nstatuscode:%{http_code}\n")
echo $resp > $INFO_OUTPUT
http=$(echo "$resp" | fgrep statuscode | sed -e 's/^statuscode://')
echo "$http" | test_ok step6.post_update || FAIL "update collaboration failed"

resp=$(curl_graph_store_get --url "$COLLAB_EP" -H "Authorization: Bearer $STORE_TOKEN" -H "Accept: application/json" -w "\nstatuscode:%{http_code}\n")
echo updated response: $resp > $INFO_OUTPUT
current_collab=$(echo "$resp" | sed -e 's/^statuscode:.*//')
if json_contains "$update_collab" "$current_collab"; then
  modes_after_update=$(get_jhacker_acl_modes)
  echo updated sparql response: ${modes_after_update} > $INFO_OUTPUT
  if json_contains '[{"mode": "http://www.w3.org/ns/auth/acl#Read" }, {"mode": "http://www.w3.org/ns/auth/acl#Write" }]' "${modes_after_update}"; then
    INFO "Step 6c metadata verification succeeded"
  else
    FAIL "ctep 6c collaboration metadata not propagated to system repository"; exit 1;
  fi
else
  FAIL "update verification failed"; exit 1;
fi

# --- delete collaboration ----------------------------------------------------
delete_collab='[{"account":"jhacker"}]'

INFO "Step 6d: delete collaboration jhacker"
resp=$(curl_graph_store_post --url "$COLLAB_EP" \
      -H "Authorization: Bearer $STORE_TOKEN" \
      -H "Content-Type: application/json" \
      -H "Accept: application/json" \
      --data "$delete_collab" -w "\nstatuscode:%{http_code}\n")
http=$(echo "$resp" | fgrep statuscode | sed -e 's/^statuscode://')
echo "$http" | test_ok step6.post_delete || FAIL "delete collaboration failed"

resp=$(curl_graph_store_get --url "$COLLAB_EP" -H "Authorization: Bearer $STORE_TOKEN" -H "Accept: application/json" -w "\nstatuscode:%{http_code}\n")
echo deleted response: $resp > $INFO_OUTPUT
current_collab=$(echo "$resp" | sed -e 's/^statuscode:.*//')
# verify deletion from API response
if json_contains "$delete_collab" "$current_collab"; then
  FAIL "delete verification failed (still present)"; exit 1
fi
# additionally ensure the ACL metadata has been cleaned up
 modes_after_delete=$(get_jhacker_acl_modes | sed -e 's/ //g')
 echo deleted sparql response: ${modes_after_delete} > $INFO_OUTPUT
  if [ "[]" == "${modes_after_delete}" ]; then
    INFO "Step 6f metadata verification succeeded"
  else
    FAIL "ctep 6d collaboration metadata not propagated to system repository"; exit 1;
  fi

# restore original collaborations if any
if [[ -n "$orig_collab" ]]; then
  curl_graph_store_post --url "$COLLAB_EP" -H "Authorization: Bearer $STORE_TOKEN" -H "Content-Type: application/json" -H "Accept: application/json" --data "$orig_collab" -w "%{http_code}" -o /dev/null
  INFO "Step 6e: restored original collaboration set"
fi

INFO "All service-administration tests completed."

