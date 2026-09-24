#!/usr/bin/env bash
# Run the bats unit tests, fetching pinned versions of bats and its helper libraries.
set -euo pipefail

BATS_DIR="$(mktemp -d)"
trap 'rm -rf "${BATS_DIR}"' EXIT
for spec in bats-core@v1.14.0 bats-support@v0.3.0 bats-assert@v2.2.4; do
    git -c advice.detachedHead=false clone --quiet --depth 1 --branch "${spec#*@}" \
        "https://github.com/bats-core/${spec%@*}" "${BATS_DIR}/${spec%@*}"
done

# The tests load `${BATS_PLUGIN_PATH}/load.bash`, as provided by `buildkite/plugin-tester`
cat > "${BATS_DIR}/load.bash" <<EOL
source "${BATS_DIR}/bats-support/load.bash"
source "${BATS_DIR}/bats-assert/load.bash"
EOL
export BATS_PLUGIN_PATH="${BATS_DIR}"

cd "$(dirname "${BASH_SOURCE[0]}")/.."
"${BATS_DIR}/bats-core/bin/bats" tests/
