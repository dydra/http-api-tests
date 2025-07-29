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
INFO()  { echo -e "${BLUE}[INFO]${NC} $(basename "$0"): $*" > "$ECHO_OUTPUT"; }
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
  node - <<'JS' "$want" "$have"
 // console.log(process.argv);
const want = JSON.parse(process.argv[2]);
const have = JSON.parse(process.argv[3]);
for (const [k, v] of Object.entries(want)) {
  if (!(k in have) || String(have[k]).replace(/\s+/g, '') !== String(v).replace(/\s+/g, '')) {
    console.error(`Mismatch for ${k}: expected ${v}, got ${have[k]}`);
    console.error('WANT:\n' + JSON.stringify(want, null, 2));
    console.error('HAVE:\n' + JSON.stringify(have, null, 2));
    process.exit(1);
  }
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
http=$(echo "$resp" | fgrep statuscode | sed -e's/^statuscode://')
orig_account_cfg=$(echo "$resp" | sed -e 's/^statuscode:.*//')
echo "$http" | test_ok step1.account || { echo "step1.account failed"; exit 1; }

resp=$(curl_graph_store_get --url "$REPO_CFG_EP" \
        -H "Authorization: Bearer $STORE_TOKEN" \
        -H "Accept: application/json" \
        -w "\nstatuscode:%{http_code}\n")
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
new_repo_cfg='{ "abstract":"Meta Repo", "description":"meta description", "privacySetting":"readByAuthenticatedUserOrIP", "prefixes":"PREFIX xx: <http://xx.org/ns#>\n" }'

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
if json_contains "$orig_repo_cfg" "$restored_repo_cfg"; then
  INFO "Step 5: restore original repository configuration succeeded"
else
  FAIL "step5.verify_restore_repo failed"
  exit 1
fi

INFO "All service-administration tests completed."

