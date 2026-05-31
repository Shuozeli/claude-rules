#!/usr/bin/env bash
# Copies generated Codex rules into downstream Shuozeli repos.
# Run from anywhere. By default this only writes files.
# Pass --commit to commit each changed repo, and --push to commit and push.

set -uo pipefail

RULES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECTS_DIR="${PROJECTS_DIR:-$HOME/projects/shuozeli}"
COMMIT=false
PUSH=false

for arg in "$@"; do
  case "$arg" in
    --commit)
      COMMIT=true
      ;;
    --push)
      COMMIT=true
      PUSH=true
      ;;
    *)
      echo "unknown argument: $arg" >&2
      exit 2
      ;;
  esac
done

python3 "$RULES_ROOT/scripts/build-codex-agents.py"

REPO_PATHS=(
  compilers/protobuf-rs
  compilers/flatbuffers-rs
  codegen/codegen-infra
  codegen/schemahub
  viewers/fbsviewer
  viewers/fbsviewer-lib
  viewers/protoviewer-lib
  database/quiver-orm
  database/arrow-adbc-rs
  database/prisma-rs
  database/stonedb
  networking/pure-grpc-rs
  networking/grpcurl-rs
  networking/taskq-rs
  applications/multipost
  applications/telesync
  applications/yt-dlp-rs
  applications/issue-tracker-lite
  applications/pwright
  applications/myfeed
  applications/beu
  applications/rterm
  applications/headlines
  applications/sky-piano
  applications/ai-video-framework
  platforms/open-plx
  ai-infra/apple-ml-server
  ai-infra/litevikings
  ai-infra/ast-cli
  ai-pipelines/ai-pipelines
  ai-pipelines/claude-rules
)

updated=0
skipped=0
failed=0

for repo in "${REPO_PATHS[@]}"; do
  dir="$PROJECTS_DIR/$repo"

  if [[ ! -d "$dir/.git" ]]; then
    echo "SKIP  $repo (not a git repo at $dir)"
    ((skipped++))
    continue
  fi

  echo -n "UPDATE $repo ... "

  if ! python3 "$RULES_ROOT/scripts/install-codex-rules.py" "$RULES_ROOT" "$dir"; then
    echo "FAILED (install)"
    ((failed++))
    continue
  fi

  if [[ -z "$(cd "$dir" && git status --short -- AGENTS.md .codex/rules/shared)" ]]; then
    echo "already up to date"
    ((skipped++))
    continue
  fi

  if ! $COMMIT; then
    echo "written"
    ((updated++))
    continue
  fi

  if ! (cd "$dir" && git add AGENTS.md .codex/rules/shared && git commit -m "Add shared Codex rules" --quiet); then
    echo "FAILED (commit)"
    ((failed++))
    continue
  fi

  echo "committed"

  if $PUSH; then
    if (cd "$dir" && git push --quiet 2>/dev/null); then
      echo "       pushed"
    else
      echo "       push FAILED"
      ((failed++))
      continue
    fi
  fi

  ((updated++))
done

echo ""
echo "Done: $updated updated, $skipped skipped, $failed failed"
