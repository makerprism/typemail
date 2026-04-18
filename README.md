# typemail

**A typed DSL for HTML emails that render everywhere, including Outlook.**

`typemail` is an OCaml library (today) and a language-agnostic CLI (soon) for authoring transactional emails as composable typed components. The types guarantee that the emitted HTML degrades gracefully across every mainstream email client — including the hostile ones (Outlook Desktop 2007-2024, Gmail's media-query-stripping web client, Apple Mail, Yahoo, iOS Mail).

## Status

Pre-alpha. The API is being designed; nothing is stable yet. No opam release.

## Design pillars

- **React Email ergonomics, without the JS lock-in.** Compose emails from semantic components (`Section`, `Column`, `Heading`, `Paragraph`, `Button`, `Image`, `Divider`, `Spacer`, `Footer`) — not raw HTML.
- **No escape hatches.** MJML's `<mj-raw>` is the single biggest source of cross-client bugs in MJML codebases. typemail has no equivalent. If a pattern isn't expressible, the right answer is to add a typed component, not to punch a hole.
- **Types enforce cross-client safety.** A gradient's record type has a required `fallback: color` field. A button requires an explicit pixel width and height. Make illegal states unrepresentable.
- **Proper semantic elements for accessibility.** Headings are `Heading`, paragraphs are `Paragraph`, lists are `List`. No single `Text` component used for everything (the MJML a11y gap).
- **Truth source:** [caniemail.com](https://www.caniemail.com/). Every component's compatibility claim cites the entry in caniemail that backs it.
- **Honest about platform limits.** Gmail strips media queries. Outlook ignores `linear-gradient`. The renderer returns an error when a rendered email exceeds Gmail's 102 KB clip threshold.

## Scope

typemail **is**:

- **A typed DSL for email content.** Compose emails from semantic components: `Section`, `Column`, `Heading`, `Paragraph`, `Button`, `Image`, `Divider`, `Spacer`, `Footer`. No raw HTML in the author-facing surface.
- **Cross-client safety by construction.** A gradient's record type has a required `fallback: color` field — you cannot represent a gradient without a fallback. A button requires an explicit pixel width and height (Outlook needs these inline). Illegal states are not representable.
- **A portable renderer.** The OCaml library emits cross-client HTML (table-layout, VML fallbacks for Outlook, solid-color fallbacks before gradients, explicit pixel dimensions). The Phase 2 CLI will emit the same HTML from a text input, so consumers in any language can shell out.
- **Accessibility-aware.** `Heading level:[`H1 | `H2 | …]` and `Paragraph` are distinct components so screen readers can distinguish structure. Images require `alt`. Unlike MJML, `Heading` is never silently downgraded to a `Text` node.
- **Opinionated.** Every component cites the [caniemail.com](https://www.caniemail.com/) entries it relies on. When Gmail changes something, we know which components to re-verify.

## Phases

**Phase 1 — OCaml library.** The typed DSL + HTML renderer as an OCaml library, consumable via dune + opam. This is the reference implementation. Target: drop in to an OCaml backend and replace a hand-rolled `email_service.ml`.

**Phase 2 — CLI.** A single static binary that reads a textual form of the DSL (likely an `.mail` file plus JSON props) and emits HTML. Any language can shell out. Modeled on MJML's CLI ergonomics, not its semantics.

**Phase 3 — host-language bindings.** Thin Python / Ruby / JS wrappers that shell out to the CLI. Optional — most users will be happy calling the CLI directly from a Makefile or build step.

typemail **is not**:

- **A raw-HTML builder.** There is no `raw_html : string -> element`. There is no `mj-raw` equivalent. If a pattern isn't expressible via a typed component, the fix is a new typed component, not an escape hatch. This is the single biggest bet the library makes.
- **An MJML-format-compatible renderer.** Other projects fill that niche well: [MRML](https://github.com/jdrouet/mrml) (Rust), [gomjml](https://github.com/preslavrachev/gomjml) (Go), the [official MJML](https://github.com/mjmlio/mjml) (JavaScript). typemail is a different (stricter, opinionated) DSL — not a reimplementation.
- **A React Email port.** No JSX, no virtual DOM, no React runtime. The ergonomics should feel familiar to React Email users, but the implementation is pure OCaml.
- **An email-sending library.** Pairs with [letters](https://github.com/oxidizing/letters) (SMTP), direct AWS SES / Postmark / Resend API calls, or anything else that accepts a string.
- **A visual drag-and-drop editor.** Emails are authored as code. If you want drag-and-drop, use [Beefree](https://beefree.io/) or [Maizzle](https://maizzle.com/)'s visual tooling.
- **A marketing-email framework.** Opinionated toward transactional email (invites, receipts, notifications). Marketing-email use-cases with complex conditional blocks and A/B variants are out of scope for v1.
- **A spam-classification avoider.** typemail emits clean HTML, which helps. But deliverability is a function of your sending domain, DKIM/SPF/DMARC setup, and content — not your HTML generator.

## Design inspirations

We are building on the shoulders of these projects. All are MIT-licensed, so we can study code, borrow ideas freely, and contribute back upstream where it makes sense.

| Project | License | What we learn from it |
|---|---|---|
| [React Email](https://react.email/) ([repo](https://github.com/resend/react-email)) | MIT | Component-based ergonomics, dev preview UX, the bar for developer experience in 2026. |
| [MJML](https://mjml.io/) ([repo](https://github.com/mjmlio/mjml)) | MIT | Component set (the ~26 components cover the transactional-email space well), HTML generation patterns, cross-client test heuristics, VML Outlook fallbacks. We diverge on `<mj-raw>`. |
| [MRML](https://github.com/jdrouet/mrml) | MIT | How to do a native, non-Node MJML-style renderer in a typed language. Fast enough to be called per-email at request time. |
| [gomjml](https://github.com/preslavrachev/gomjml) | MIT | Another native implementation worth studying for component-dispatch patterns and CLI shape. |
| [Elm send-grid / Email.Html](https://github.com/MartinSStewart/send-grid) | MIT | The safe-tags allowlist design at the primitive HTML layer. Our `Typemail.Html` primitives start from this list. |
| [caniemail.com](https://www.caniemail.com/) | — | The single source of truth for "does this CSS property work in this client." Every component's compatibility claim cites caniemail. |

## Why not React Email?

React Email has excellent ergonomics, but TypeScript allows `any` and `dangerouslySetInnerHTML` — one desperate engineer can break the cross-client guarantee for everyone. typemail's OCaml types make unsafe HTML unrepresentable, and the Phase 2 CLI works from any language.

## Why not MJML/MRML?

MJML's `<mj-raw>` is the single biggest source of cross-client bugs in MJML codebases. MRML faithfully ports this — typemail rejects it. We also surface Outlook constraints (button pixel dimensions, VML for shapes) in the type system, not in documentation you might miss.

## Getting started

typemail v0.1 is now available for integration into OCaml backends.

### Installation

Add typemail to your `dune-project`:

```lisp
(depends
  (typemail (>= 0.1)))
```

Run `dune pkg lock` to generate the lockfile, then `dune build` to install.

### Usage

```ocaml
open Typemail

let invitation_email ~inviter_name ~presence_name ~invitation_url =
  (* Build email using typed components *)
  let body = Section.v [
    (* Gradient header with Outlook fallback *)
    Section.to_element @@ Section.make
      ~background:(Color.gradient
        ~direction:"to bottom"
        ~colors:["#312e81"; "#4f46e5"]
        ~fallback:(Color.solid "#312e81"))
      ~padding:(Spacing.Spacing.px32)
      ~children:[
        Heading.to_element @@ Heading.h1 ~color:Color.Brand.white
          (Printf.sprintf "You're invited to %s" presence_name);
        Paragraph.to_element @@ Paragraph.v ~color:Color.Brand.white
          (Printf.sprintf "%s invited you to collaborate." inviter_name);
      ]
      () ;

    (* Call-to-action button with VML for Outlook *)
    Section.to_element @@ Section.make
      ~padding:(Spacing.Spacing.px24)
      ~children:[
        Button.to_element @@ Button.v
          ~href:invitation_url
          ~background:(Color.solid "#4f46e5")
          ~text_color:Color.Brand.white
          ~width_px:200
          ~height_px:44
          "Accept invitation";
      ]
      () ;
  ] in

  (* Render to complete HTML document *)
  match Render.render_email body with
  | Ok html -> html
  | Error msg ->
      Printf.printf "Error: %s\n" msg;
      ""
```

### Key Benefits

✅ **Type-safe**: Required fields (alt text, button dimensions) enforced at compile time
✅ **Cross-client**: VML fallbacks for Outlook, gradients with fallbacks
✅ **No escape hatches**: Can't inject raw HTML, preventing XSS bugs
✅ **Accessibility**: Distinct Heading levels, required alt text
✅ **caniemail-backed**: Every component cites compatibility documentation

See `docs/examples/invitation.ml` for a complete working example.

## Contributing

Read [`AGENTS.md`](./AGENTS.md) before contributing. It's written for AI agents but applies equally to humans: it defines the engineering discipline, coding style, testing approach, and branching model for the repo.

## License

[MIT](./LICENSE) © Makerprism.
