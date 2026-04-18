# Agent Guidelines for typemail

Compact operating guide for AI agents working in this repo.

## 1) What typemail is

`typemail` is a typed DSL for authoring HTML emails that render correctly across every mainstream email client — including the hostile ones (Outlook Desktop 2007-2024, Gmail's media-query-stripping web client, Apple Mail, Yahoo, etc.).

**Design pillars:**

- **React Email ergonomics, without the JS lock-in.** Compose emails from semantic components (`Section`, `Column`, `Heading`, `Paragraph`, `Button`, `Image`, `List`) — not raw HTML.
- **No escape hatches.** MJML's `<mj-raw>` is the single biggest source of cross-client bugs in MJML codebases. typemail has no equivalent. If a pattern isn't expressible, the right answer is to add a typed component, not to punch a hole.
- **Types enforce cross-client safety.** A gradient's record type has a required `fallback: color` field. A button requires an explicit pixel width and height. Make illegal states unrepresentable.
- **Proper semantic elements for accessibility.** Headings are `Heading`, paragraphs are `Paragraph`, lists are `List`. No single `Text` component used for everything (the MJML a11y gap).
- **Truth source:** [caniemail.com](https://www.caniemail.com/). Every component's compatibility claim cites the entry in caniemail that backs it.
- **Honest about platform limits.** Gmail strips media queries. Outlook ignores `linear-gradient`. The compiler warns when a rendered email exceeds Gmail's 102 KB clip threshold.

## 2) Phased scope

**Phase 1 — OCaml library.** The typed DSL + HTML renderer as an OCaml library, consumable via dune + opam. This is the reference implementation. Target: drop in to an OCaml backend and replace a hand-rolled `email_service.ml`.

**Phase 2 — CLI.** A single static binary that reads a textual form of the DSL (likely an `.mail` file plus JSON props) and emits HTML. Any language can shell out. Modeled on MJML's CLI ergonomics, not its semantics.

**Phase 3 — host-language bindings.** Thin Python / Ruby / JS wrappers that shell out to the CLI. Optional — most users will be happy calling the CLI directly from a Makefile or build step.

Agents working in this repo should keep subsequent phases in mind when designing Phase 1 APIs — the OCaml API should be the most ergonomic surface, but the element set and schema should be portable to a text format later without redesign.

## 3) Required reading before coding

1. This file (`AGENTS.md`).
2. [OCaml Coding Style](https://github.com/makerprism/coding-discipline/blob/main/CODING_STYLE.md) — **hard constraint** for all code in this repo.
3. [caniemail.com](https://www.caniemail.com/) — every component-level compatibility claim must cite its caniemail entry.
4. Anything under `docs/` once it exists (architecture notes, DSL spec drafts).

## 4) Working loop

1. Gather context from the reading list above.
2. Implement. Every public module has an `.mli`; every public type has a doc comment explaining *why* it's shaped that way.
3. Update docs when behavior or architecture changes — in the same PR, never as a separate cleanup.
4. Run the required checks in section 9 before pushing.

## 5) Engineering principles

**Always choose the clean long-term solution over short-term hacks.** When facing the choice between a quick workaround and a proper refactor, choose the refactor. Every time. Short-term hacks compound.

**Priority order: maintainability > reliability > simplicity > correctness.** A simpler solution that is easy to maintain and works reliably is preferable to a "more correct" solution that adds architectural complexity. Correctness matters, but not at the cost of the first three.

**Make illegal states unrepresentable.** This matters more in typemail than in most projects: the library's value proposition *is* type-enforced safety. If a user can represent a bad email, we've failed. Preferred idioms: opaque types, private constructors with validators, record fields that are non-optional where MJML has them optional.

**Meticulous codebase cleanliness is non-negotiable.** When the same pattern appears in 3+ places, extract it. When you add a new component, match the existing pattern exactly — divergence in style within the same pattern is a bug. Delete dead code immediately; don't leave it for "later."

**Feature PRs must include related cleanups.** If you notice dead code, outdated docs, or leftover scaffolding adjacent to your change, delete it in the same PR. Deferred cleanup rarely happens.

## 6) OCaml coding style

All code must conform to the [OCaml Coding Style](https://github.com/makerprism/coding-discipline/blob/main/CODING_STYLE.md). Non-conforming code must not be merged. Key points (see the full guide):

- Zero warnings: compile with warnings as errors.
- `snake_case` names; module names match filenames (no PascalCase aliases).
- Qualified module access everywhere. No top-level `open`.
- ADTs over strings for closed sets; exhaustive pattern matching (no `| _ ->` catch-alls).
- Make illegal states unrepresentable: domain-oriented opaque types, `option` for nullability, parse at the boundary.
- `result` for expected failures, exceptions for bugs only.
- No mutable state; pure functions are the default.
- Tail-recursive implementations for unbounded input.
- Functions ~70 lines max.
- `.mli` files for public modules; comments explain *why*, not *what*.
- Libraries must be runtime-agnostic (no Lwt/Eio dependency in library code). typemail's core rendering is pure — side effects belong to consumers.
- `ocamlformat` handles all formatting. Do not bikeshed whitespace.

## 7) Dependency management (dune, not opam)

**Use `dune` for all dependency management. Never `opam`.**

- `dune-project` is the single source of truth for dependencies and pins.
- `dune.lock/` is a generated artifact. Never edit lock files directly. Always update pins in `dune-project` and run `dune pkg lock` to regenerate.
- To add a dependency: edit `dune-project`, run `dune pkg lock`, commit both the `dune-project` change and the regenerated `dune.lock/`.
- To patch an upstream library in the `makerprism` GitHub org: push the fix to their `main` branch first, then update `dune-project` to pin the newest commit hash and run `dune pkg lock`.

## 8) Branch, commit, and PR discipline

- Default integration branch: `main`.
- **Always use `origin/main`, never local `main`.** Local `main` may be stale. Always `git fetch origin` and compare against `origin/main` for branch diffs, ancestry checks, and rebase targets.
- **Rebase on `origin/main` before merging.** Use `git fetch origin && git rebase origin/main`. Never rebase on a local `main`. Never use `git merge` or `git pull` without `--rebase`. Merge commits are rejected by the pre-push hook.
- **PRs merge to `main` via squash only.** No merge-commit, no rebase-merge.
- On push rejection, rebase on `origin/main` and resolve conflicts autonomously. Escalate only for truly ambiguous business-logic conflicts.
- Never skip pre-push hooks (`--no-verify`). Never skip commit signing. Fix hook failures in follow-up commits.
- Commit messages explain *why*, not *what* — the diff shows what.
- PR descriptions include a test plan.

## 9) Required checks before pushing

1. `dune build` — clean, zero warnings.
2. `dune test` — all tests pass.
3. `dune fmt` — formatting applied.
4. Renderer golden tests pass against the cross-client HTML snapshots in `test/golden/` (see section 10).
5. Docs touched if public API changed.

## 10) Cross-client testing

The library's value is "emits HTML that works across email clients." That has to be backed by tests, not hope.

- **Golden-file snapshot tests.** For every component, capture the rendered HTML in `test/golden/<component>.html`. Changes to the rendered output require updating the golden file, which surfaces cross-client implications in review.
- **caniemail citations.** Every component's doc comment cites the caniemail entries that back its compatibility claim. When caniemail changes upstream (new Outlook version, new Gmail quirk), we know exactly which components to re-verify.
- **Reference corpus.** `test/corpus/` holds example emails that exercise the full component set. These render to HTML and are included in the docs as executable reference. When we can afford it (or can partner with Litmus / Email on Acid), the corpus becomes the input to a real cross-client test pipeline.

Until a real client matrix is wired up, every PR that adds or changes a component *must* include:
- Updated golden-file snapshot.
- Manual verification claim in the PR description: "Rendered in Gmail web, Outlook 2019 desktop, Apple Mail." Screenshots if the component is visually load-bearing.

## 11) Documentation maintenance

Docs that don't evolve with code become lies. Stale docs are bugs.

- Every public module has an `.mli` with doc comments on every type and function.
- Architecture decisions live in `docs/architecture/` as short ADRs (one per decision, numbered).
- When behavior changes, update the affected docs in the same PR — never as a "cleanup" follow-up.
- Examples and tutorials belong under `docs/examples/` and must compile (they're built as part of `dune build`).

## 12) The sacred rules

1. No new files without reuse analysis and concrete justification.
2. No rewrites where incremental refactor works.
3. Extend existing architecture patterns; avoid parallel systems.
4. Implement and verify before writing documentation.
5. Verify claims against actual diff (`git diff --stat`).
6. Delete dead code immediately.
7. Never claim something works unless it has been validated. "Validated" means either the maintainer confirmed it works or it's covered by a passing test. Code compiling and deploying is not validation — it only proves the code builds.

## 13) Collaborating with agents

When briefing an agent on a typemail task, include:
- The target component or module (e.g. `Email.Button`).
- The caniemail entries that constrain the design.
- Whether this is a Phase 1 (OCaml library) or Phase 2 (CLI/schema) concern.
- Expected cross-client behavior (what should work in Outlook, what should degrade).

Agents should refuse to add escape hatches (e.g. `raw_html : string -> element`). If a pattern isn't expressible through typed components, the right answer is to propose a new typed component — not to bypass the type system.
