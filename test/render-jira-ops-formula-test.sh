#!/usr/bin/env bash
set -euo pipefail

repository_root=$(cd "$(dirname "$0")/.." && pwd)
renderer="$repository_root/script/render-jira-ops-formula"
fixture_root=$(mktemp -d)
trap 'rm -rf -- "$fixture_root"' EXIT

version=0.2.0-beta.2
dist="$fixture_root/dist"
output="$fixture_root/jira-ops.rb"
mkdir -p "$dist"

targets=(
  aarch64-apple-darwin
  x86_64-apple-darwin
  aarch64-unknown-linux-gnu
  x86_64-unknown-linux-gnu
)
hashes=(
  aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
  bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
  cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
  dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
)

for index in "${!targets[@]}"; do
  archive="jira-ops-v$version-${targets[$index]}.tar.gz"
  printf 'fixture for %s\n' "${targets[$index]}" > "$dist/$archive"
  printf '%s  %s\n' "${hashes[$index]}" "$archive" > "$dist/$archive.sha256"
done

"$renderer" "$version" "$dist" "$output"

formula_mode=$(stat -f '%Lp' "$output" 2>/dev/null || stat -c '%a' "$output")
[[ "$formula_mode" == 644 ]] || {
  printf 'generated formula mode is %s, expected 644\n' "$formula_mode" >&2
  exit 1
}

assert_contains() {
  local expected=$1
  grep -Fq -- "$expected" "$output" || {
    printf 'generated formula is missing: %s\n' "$expected" >&2
    exit 1
  }
}

assert_contains 'class JiraOps < Formula'
assert_contains 'license any_of: ["MIT", "Apache-2.0"]'
assert_contains 'jira-ops-v0.2.0-beta.2-aarch64-apple-darwin.tar.gz'
assert_contains 'sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"'
assert_contains 'jira-ops-v0.2.0-beta.2-x86_64-apple-darwin.tar.gz'
assert_contains 'sha256 "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"'
assert_contains 'jira-ops-v0.2.0-beta.2-aarch64-unknown-linux-gnu.tar.gz'
assert_contains 'sha256 "cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"'
assert_contains 'jira-ops-v0.2.0-beta.2-x86_64-unknown-linux-gnu.tar.gz'
assert_contains 'sha256 "dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd"'
assert_contains 'bin.install "jira-ops"'
assert_contains 'assert_match version.to_s, shell_output("#{bin}/jira-ops version")'

printf 'renderer success contract passed\n'

invalid_stderr="$fixture_root/invalid-version.stderr"
if "$renderer" 'release-candidate' "$dist" "$fixture_root/invalid.rb" 2> "$invalid_stderr"; then
  echo 'renderer accepted a malformed release version' >&2
  exit 1
fi
grep -Fq 'invalid release version: release-candidate' "$invalid_stderr" || {
  echo 'malformed-version failure did not identify the invalid value' >&2
  exit 1
}

printf 'renderer invalid-version contract passed\n'

missing_archive="$dist/jira-ops-v$version-aarch64-apple-darwin.tar.gz"
mv "$missing_archive" "$missing_archive.saved"
missing_stderr="$fixture_root/missing-archive.stderr"
if "$renderer" "$version" "$dist" "$fixture_root/missing.rb" 2> "$missing_stderr"; then
  mv "$missing_archive.saved" "$missing_archive"
  echo 'renderer accepted a missing release archive' >&2
  exit 1
fi
mv "$missing_archive.saved" "$missing_archive"
grep -Fq 'missing release archive: jira-ops-v0.2.0-beta.2-aarch64-apple-darwin.tar.gz' "$missing_stderr" || {
  echo 'missing-archive failure did not identify the absent file' >&2
  exit 1
}

printf 'renderer missing-archive contract passed\n'

mismatched_sidecar="$dist/jira-ops-v$version-x86_64-apple-darwin.tar.gz.sha256"
cp "$mismatched_sidecar" "$mismatched_sidecar.saved"
printf '%s  %s\n' "${hashes[1]}" 'different-archive.tar.gz' > "$mismatched_sidecar"
mismatched_stderr="$fixture_root/mismatched-checksum.stderr"
if "$renderer" "$version" "$dist" "$fixture_root/mismatched.rb" 2> "$mismatched_stderr"; then
  mv "$mismatched_sidecar.saved" "$mismatched_sidecar"
  echo 'renderer accepted a checksum for another archive' >&2
  exit 1
fi
mv "$mismatched_sidecar.saved" "$mismatched_sidecar"
grep -Fq 'invalid release checksum: jira-ops-v0.2.0-beta.2-x86_64-apple-darwin.tar.gz.sha256' "$mismatched_stderr" || {
  echo 'mismatched-checksum failure did not identify the invalid sidecar' >&2
  exit 1
}

printf 'renderer mismatched-checksum contract passed\n'

missing_sidecar="$dist/jira-ops-v$version-aarch64-unknown-linux-gnu.tar.gz.sha256"
mv "$missing_sidecar" "$missing_sidecar.saved"
sidecar_stderr="$fixture_root/missing-sidecar.stderr"
if "$renderer" "$version" "$dist" "$fixture_root/missing-sidecar.rb" 2> "$sidecar_stderr"; then
  mv "$missing_sidecar.saved" "$missing_sidecar"
  echo 'renderer accepted a missing checksum sidecar' >&2
  exit 1
fi
mv "$missing_sidecar.saved" "$missing_sidecar"
grep -Fq 'missing release checksum: jira-ops-v0.2.0-beta.2-aarch64-unknown-linux-gnu.tar.gz.sha256' "$sidecar_stderr" || {
  echo 'missing-sidecar failure did not identify the absent file' >&2
  exit 1
}

printf 'renderer missing-sidecar contract passed\n'

malformed_sidecar="$dist/jira-ops-v$version-x86_64-unknown-linux-gnu.tar.gz.sha256"
cp "$malformed_sidecar" "$malformed_sidecar.saved"
printf '%s  %s\n' 'not-a-sha256' "jira-ops-v$version-x86_64-unknown-linux-gnu.tar.gz" > "$malformed_sidecar"
malformed_stderr="$fixture_root/malformed-checksum.stderr"
if "$renderer" "$version" "$dist" "$fixture_root/malformed-checksum.rb" 2> "$malformed_stderr"; then
  mv "$malformed_sidecar.saved" "$malformed_sidecar"
  echo 'renderer accepted a malformed checksum digest' >&2
  exit 1
fi
mv "$malformed_sidecar.saved" "$malformed_sidecar"
grep -Fq 'invalid release checksum: jira-ops-v0.2.0-beta.2-x86_64-unknown-linux-gnu.tar.gz.sha256' "$malformed_stderr" || {
  echo 'malformed-checksum failure did not identify the invalid sidecar' >&2
  exit 1
}

printf 'renderer malformed-checksum contract passed\n'

ci_workflow="$repository_root/.github/workflows/ci.yml"
[[ -f "$ci_workflow" ]] || {
  echo 'tap CI workflow is missing' >&2
  exit 1
}

assert_workflow_contains() {
  local expected=$1
  grep -Fq -- "$expected" "$ci_workflow" || {
    printf 'tap CI workflow is missing: %s\n' "$expected" >&2
    exit 1
  }
}

for expected in \
  'pull_request:' \
  'workflow_dispatch:' \
  'macos-15' \
  'ubuntu-24.04' \
  'bash test/render-jira-ops-formula-test.sh' \
  'ruby -c Formula/jira-ops.rb' \
  'brew style Formula/jira-ops.rb' \
  'brew audit --strict --online amaljithkuttamath/tap/jira-ops' \
  'brew install amaljithkuttamath/tap/jira-ops' \
  'brew test amaljithkuttamath/tap/jira-ops' \
  'jira-ops version'
do
  assert_workflow_contains "$expected"
done

if grep -E '^[[:space:]]*uses:' "$ci_workflow" | grep -Ev '@[0-9a-f]{40}([[:space:]]|$)' >/dev/null; then
  echo 'tap CI workflow contains an action that is not pinned to a full commit SHA' >&2
  exit 1
fi

printf 'tap CI contract passed\n'

update_workflow="$repository_root/.github/workflows/update-jira-ops.yml"
[[ -f "$update_workflow" ]] || {
  echo 'jira-ops formula updater workflow is missing' >&2
  exit 1
}

assert_updater_contains() {
  local expected=$1
  grep -Fq -- "$expected" "$update_workflow" || {
    printf 'jira-ops updater workflow is missing: %s\n' "$expected" >&2
    exit 1
  }
}

for expected in \
  'schedule:' \
  'workflow_dispatch:' \
  'contents: write' \
  'pull-requests: write' \
  'actions: write' \
  'gh release download "$tag"' \
  'sha256sum --check' \
  'script/render-jira-ops-formula "$version" dist Formula/jira-ops.rb' \
  'gh pr list --state open' \
  'chore: update jira-ops to $version' \
  'branch="automation/jira-ops-$safe_version-$GITHUB_RUN_ID"' \
  'gh pr create' \
  'gh workflow run ci.yml --ref "$branch"' \
  'gh run watch "$run_id" --exit-status' \
  'gh pr merge "$pr_number" --squash --delete-branch'
do
  assert_updater_contains "$expected"
done

if grep -E '^[[:space:]]*uses:' "$update_workflow" | grep -Ev '@[0-9a-f]{40}([[:space:]]|$)' >/dev/null; then
  echo 'jira-ops updater contains an action that is not pinned to a full commit SHA' >&2
  exit 1
fi

printf 'jira-ops updater contract passed\n'
