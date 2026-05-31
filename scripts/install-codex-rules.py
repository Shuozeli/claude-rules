#!/usr/bin/env python3
"""Install generated Codex rules into a target repository."""

from __future__ import annotations

import shutil
import sys
from pathlib import Path


BEGIN = "<!-- BEGIN SHUOZELI SHARED CODEX RULES -->"
END = "<!-- END SHUOZELI SHARED CODEX RULES -->"


def managed_block(shared: str) -> str:
    return "\n".join([BEGIN, shared.strip(), END, ""])


def merge_agents(existing: str, shared: str) -> str:
    block = managed_block(shared)
    if BEGIN in existing and END in existing:
        before, rest = existing.split(BEGIN, 1)
        _, after = rest.split(END, 1)
        return (before.rstrip() + "\n\n" + block + after.lstrip()).strip() + "\n"
    if existing.strip():
        return block + "\n## Repo-Local Instructions\n\n" + existing.strip() + "\n"
    return block


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("usage: install-codex-rules.py <rules-root> <target-dir>")

    rules_root = Path(sys.argv[1]).resolve()
    target_dir = Path(sys.argv[2]).resolve()
    codex_dir = rules_root / "codex"
    shared = (codex_dir / "AGENTS.md").read_text(encoding="utf-8")

    target_rules = target_dir / ".codex" / "rules"
    target_rules.mkdir(parents=True, exist_ok=True)
    target_shared = target_rules / "shared"
    if target_shared.exists():
        shutil.rmtree(target_shared)
    shutil.copytree(codex_dir, target_shared)

    agents = target_dir / "AGENTS.md"
    existing = agents.read_text(encoding="utf-8") if agents.exists() else ""
    agents.write_text(merge_agents(existing, shared), encoding="utf-8")


if __name__ == "__main__":
    main()
