# claude-rules

Shared Claude Code and Codex rules for all Shuozeli repositories.

Claude uses the source rules directly from `common/`, `api/`, and `workflows/`.
Codex uses the migrated distribution under `codex/`, especially `codex/AGENTS.md`.

## Structure

```
common/              Universal coding standards
  code-standards.md    Code style, testing, database, tech stack
  rust-quality.md      Rust-specific quality rules (clippy, traits, imports)
  dependency-management.md  Cargo dependency rules (no cross-repo path deps)
  large-refactor.md    Strategy for large file rewrites
  ci-verification.md   CI checks, phased launches, circular dependency avoidance
  spanner-schemas.md   Spanner schema design patterns (keys, interleaving, foreign keys)
api/                 API design standards
  aipdev.md            Google AIP standards (comprehensive)
  docsguide.md         Documentation format, freshness rules, MANIFEST.md
workflows/           Agent workflow patterns
  beu-workflow.md      beu session memory CLI reference
  agent-driven-learning.md  Structured agent learning pipeline
  session-management.md  Claude session tracking across conversations
codex/              Codex-compatible rule distribution
  AGENTS.md           Generated bundle read by Codex
  common/             Migrated common rules
  api/                Migrated API rules
  workflows/          Migrated workflow rules
scripts/
  build-codex-agents.py  Regenerates codex/AGENTS.md
```

## Usage

### Add to a repo (first time)

```bash
git submodule add https://github.com/shuozeli/claude-rules.git .claude/rules/shared
git commit -m "Add shared claude-rules submodule"
```

### Clone a repo that has this submodule

```bash
git clone --recurse-submodules <repo-url>
# or if already cloned:
git submodule update --init --recursive
```

### Pull latest rules into a repo

```bash
git submodule update --remote --merge
git add .claude/rules/shared
git commit -m "Update shared claude-rules"
```

### Install Codex rules into a repo

From a target repo:

```bash
/path/to/claude-rules/install-codex.sh
```

This copies `codex/` to `.codex/rules/shared/` and writes a managed shared
rules block into the repo-root `AGENTS.md` so Codex can load the shared rules.
Existing repo-local `AGENTS.md` content is preserved below the managed block.

### Update Codex rules across Shuozeli repos

```bash
./update-codex-all.sh          # write files only
./update-codex-all.sh --commit # write and commit
./update-codex-all.sh --push   # write, commit, and push
```

The script regenerates `codex/AGENTS.md`, copies it into the allowlisted
Shuozeli repos, and can optionally commit and push changed `AGENTS.md` and
`.codex/rules/shared`.

## What belongs here vs. elsewhere

| Location | What goes there |
|----------|----------------|
| **This repo** | Universal rules shared across all projects (no PII, no secrets, no repo-specific config) |
| **~/.claude/rules/** | Personal/infrastructure defaults (IPs, passwords, endpoints) |
| **repo/.claude/rules/*.md** | Repo-specific rules (project architecture, deployment, local conventions) |
| **repo/CLAUDE.md** | Repo-specific context (tech stack, build commands, project description) |
| **repo/AGENTS.md** | Codex-readable shared and repo-specific instructions |
| **repo/.codex/rules/shared/** | Local copy of the generated Codex rule distribution |

## Adding a new rule

1. Create the `.md` file in the appropriate directory
2. Add `trigger: always_on` frontmatter if the rule should always be active
3. Run `python3 scripts/build-codex-agents.py`
4. Push to main
5. For Claude submodules: in each repo, run `git submodule update --remote --merge`
6. For Codex copies: run `./update-codex-all.sh`
