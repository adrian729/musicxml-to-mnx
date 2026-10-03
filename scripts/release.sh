#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

fail() {
  echo "release: $*" >&2
  exit 1
}

wait_run() {
  local workflow=$1 sha=$2 previous=${3:-} id=""
  for _ in $(seq 60); do
    id=$(gh run list --workflow "$workflow" --commit "$sha" --branch main --json databaseId -q '.[0].databaseId')
    [ -n "$id" ] && [ "$id" != "$previous" ] && break
    sleep 5
  done
  [ -n "$id" ] && [ "$id" != "$previous" ] || fail "$workflow did not start for $sha"
  gh run watch "$id" --exit-status >/dev/null || fail "$workflow failed: $(gh run view "$id" --json url -q .url)"
}

unpublished() {
  local name version
  name=$(node -p "require('./package.json').name")
  version=$(node -p "require('./package.json').version")
  [ -n "$(npm view "$name@$version" version --fetch-retries=0 2>/dev/null)" ] || echo "$name@$version"
}

smoke() (
  release_smoke_dir=$(mktemp -d)
  trap 'rm -rf "$release_smoke_dir"' EXIT
  pnpm pack --pack-destination "$release_smoke_dir" >/dev/null
  cp test/fixtures/basic.musicxml "$release_smoke_dir/basic.musicxml"
  cd "$release_smoke_dir"
  npm init -y >/dev/null
  npm install --no-audit --no-fund ./*.tgz >/dev/null
  ./node_modules/.bin/musicxml-to-mnx basic.musicxml converted.mnx.json
  node --input-type=module -e 'import { readFileSync } from "node:fs"; import { check } from "@polyhymnia/musicxml-to-mnx"; const result = check(JSON.parse(readFileSync("converted.mnx.json", "utf8"))); if (!result.ok) throw new Error(JSON.stringify(result.problems));'
)

[ "$(git branch --show-current)" = main ] || fail "not on main"
[ -z "$(git status --porcelain)" ] || fail "working tree not clean"
git fetch origin
git merge --ff-only origin/main

pnpm install --frozen-lockfile
pnpm build
pnpm typecheck
pnpm exec vitest run --reporter=dot

if find .changeset -name '*.md' ! -name README.md | grep -q .; then
  pnpm exec changeset version
  pnpm install
  git add -A
  git commit -m "Version packages"
fi

pending=$(unpublished)
[ -n "$pending" ] || fail "nothing to release: no pending changesets and this version is on npm"

pnpm build
smoke

sha=$(git rev-parse HEAD)
git push origin main
wait_run ci.yml "$sha"
previous=$(gh run list --workflow release.yml --commit "$sha" --branch main --json databaseId -q '.[0].databaseId')
gh workflow run release.yml --ref main -f "expected_sha=$sha"
wait_run release.yml "$sha" "$previous"

for _ in $(seq 24); do
  [ -z "$(unpublished)" ] && break
  sleep 5
done
[ -z "$(unpublished)" ] || fail "not on npm after release.yml: $(unpublished)"

echo "released: $pending"
