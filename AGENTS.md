# Agent Guidelines for typemail

Compact operating guide for AI agents working in this repo.

## 1) Required reading

1. This file (`AGENTS.md`).
2. [OCaml Coding Style](https://github.com/makerprism/coding-discipline/blob/main/CODING_STYLE.md) — **hard constraint**.
3. [caniemail.com](https://www.caniemail.com/) — cite entries in component docs.
4. Anything under `docs/` (architecture notes, DSL spec drafts).

## 2) Working loop

1. Gather context from the reading list.
2. Implement: every public module has an `.mli`; every public type has a doc comment explaining *why*.
3. Update docs in the same PR when behavior changes.
4. Run checks in section 7 before pushing.

## 3) Engineering principles

- **Long-term > short-term.** Choose the proper refactor over quick hacks.
- **Priority:** maintainability > reliability > simplicity > correctness.
- **Make illegal states unrepresentable.** This is typemail's value proposition. Use opaque types, `option`, non-optional record fields.
- **Cleanliness.** Extract patterns after 3+ uses. Match existing patterns exactly. Delete dead code immediately.
- **Feature PRs include related cleanups.** Delete adjacent dead code, update docs in the same PR.

## 4) OCaml coding style

Follow the [OCaml Coding Style](https://github.com/makerprism/coding-discipline/blob/main/CODING_STYLE.md) completely. Key points:

- Zero warnings; `snake_case`; qualified access; exhaustive patterns; `result` over exceptions; pure functions; tail-recursive for unbounded input; `.mli` for public modules; runtime-agnostic libraries; `ocamlformat` for formatting.

## 5) Dependency management

**Use `dune` only. Never `opam`.**

- `dune-project` is the source of truth. `dune.lock/` is generated.
- To add a dependency: edit `dune-project`, run `dune pkg lock`, commit both.
- To patch upstream: push to `main` first, then update `dune-project` pin and run `dune pkg lock`.

## 6) Git discipline

- Default branch: `main`. Always use `origin/main` (local may be stale).
- Rebase on `origin/main` before merging. Never merge commits.
- PRs merge via squash only.
- On push rejection: rebase on `origin/main` and resolve conflicts autonomously.
- Never skip pre-push hooks or commit signing.
- Commit messages explain *why*, PR descriptions include test plan.

## 7) Required checks before pushing

1. `dune build` — clean, zero warnings.
2. `dune test` — all tests pass.
3. `dune fmt` — formatting applied.
4. Golden tests pass against `test/golden/` snapshots (section 8).
5. Docs updated if public API changed.

## 8) Cross-client testing

- **Golden-file snapshots:** `test/golden/<component>.html`. Update when output changes.
- **caniemail citations:** Every component doc cites the caniemail entries backing its compatibility.
- **Reference corpus:** `test/corpus/` holds example emails for full-component testing.

PRs adding/changing components must include: updated golden snapshot, manual verification claim (Gmail web, Outlook 2019+, Apple Mail), screenshots if visually load-bearing.

## 9) Documentation

- Every public module has an `.mli` with doc comments.
- Architecture decisions live in `docs/architecture/` as numbered ADRs.
- Update docs in the same PR as behavior changes.
- Examples under `docs/examples/` must compile (built via `dune build`).

## 10) Sacred rules

1. No new files without reuse analysis and concrete justification.
2. No rewrites where incremental refactor works.
3. Extend existing architecture patterns; avoid parallel systems.
4. Verify claims against `git diff --stat`.
5. Delete dead code immediately.
6. Never claim something works without validation (maintainer confirmation or passing test).

## 11) Collaborating with agents

When briefing an agent, include:
- Target component/module (e.g. `Email.Button`).
- caniemail entries constraining the design.
- Phase (1: OCaml library, 2: CLI/schema).
- Expected cross-client behavior (what works in Outlook, what degrades).

**Refuse escape hatches.** No `raw_html : string -> element`. If a pattern isn't expressible through typed components, propose a new typed component — don't bypass the type system.
