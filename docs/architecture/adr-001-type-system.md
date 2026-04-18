# ADR-001: Type System Design

## Status

Accepted

## Context

typemail must guarantee cross-client safety at the type level. The primary risk is developers bypassing safety checks when under time pressure.

Existing email DSLs (MJML, React Email) allow escape hatches:
- MJML: `<mj-raw>` for arbitrary HTML
- React Email: `dangerouslySetInnerHTML` prop
- TypeScript: `any` type bypasses type checking

These escape hatches are the single biggest source of cross-client bugs in production email codebases. When under deadline pressure, developers use them to "just make it work," inadvertently breaking Outlook compatibility or Gmail rendering.

## Decision

We make illegal states unrepresentable through four complementary strategies:

### 1. Opaque Types

`Element.t` is abstract (private) in the implementation. There is NO way to construct an Element.t except through the provided smart constructors.

```ocaml
(* core/element.mli *)
type t  (* Abstract - no constructors exposed *)

(* NO raw_html constructor exists *)
(* If a pattern isn't expressible, add a component, don't bypass *)
```

This prevents:
- XSS attacks via injected HTML
- Breaking cross-client compatibility with unsupported CSS/HTML
- Bypassing Outlook-specific constraints

### 2. Required Fields

Record types require safety-critical fields. Gradients MUST have a fallback. Buttons MUST have explicit dimensions.

```ocaml
type t =
  | Gradient of {
      direction: string;
      colors: string list;
      fallback: t;  (* Required solid color for Outlook *)
    }

type button = {
  href: string;
  background: Color.t;
  text_color: Color.t;
  width_px: int;   (* Required for Outlook VML *)
  height_px: int;  (* Required for Outlook VML *)
  border_radius: int option;  (* Optional - safe default *)
  content: string;
}
```

### 3. Variant Types

Heading levels cannot be wrong at compile time.

```ocaml
type level = H1 | H2 | H3 | H4 | H5 | H6

let h1 : ?color:Color.t -> string -> t
let h2 : ?color:Color.t -> string -> t
(* No way to pass an invalid level *)
```

### 4. Validation in Smart Constructors

Spacing values cannot be negative.

```ocaml
type t = private int  (* Abstract - use smart constructors *)

val of_px : int -> t option  (* Returns None if negative *)
val of_px_exn : int -> t     (* Raises if negative *)
```

## Consequences

### Positive

✅ **Impossible to construct unsafe HTML** - No escape hatch exists in the type system
✅ **Compiler guides users toward safe patterns** - Type errors explain what's missing
✅ **No runtime checks for safety** - Compile-time only, zero runtime overhead
✅ **Refactoring safety** - Changing component internals doesn't break type-level guarantees
✅ **Documentation in types** - Required fields are visible in IDE autocomplete

### Negative

❌ **More verbose than MJML for simple cases** - `Button.v ~href ~background ~text_color ~width_px ~height_px` vs `<Button href="...">`
❌ **New component patterns require library changes** - Cannot add new HTML patterns without library update
❌ **Learning curve** - Developers must understand OCaml's type system
❌ **Cannot express every possible email pattern** - Some edge cases require new component types

### Mitigations

- **Smart constructors** (`Button.v`) provide common-case ergonomics
- **Optional fields** for non-critical props reduce verbosity
- **Component library** covers 95% of transactional email use cases
- **Phase 2 CLI** allows non-OCaml backends to use the library

## Alternatives Considered

### 1. Allow `raw_html` with warning

**Rejected**: Warnings are ignored under deadline pressure. One use of `raw_html` breaks the guarantee for the entire codebase.

### 2. Runtime validation

**Rejected**: Catches bugs in testing, not at compile time. Increases runtime overhead. Doesn't help with refactoring.

### 3. Gradual typing (TypeScript-style)

**Rejected**: `any` type and type casts undermine the entire safety guarantee. OCaml's strong type system is a feature, not a bug.

### 4. Escape hatch with code review requirement

**Rejected**: Code review is a social process, not a technical control. Under time pressure, shortcuts get approved.

## References

- [OCaml Coding Style](https://github.com/makerprism/coding-discipline/blob/main/CODING_STYLE.md) - Zero warnings, exhaustive patterns, result over exceptions
- [Making Illegal States Unrepresentable](https://blog.stenmans.com/theBeamWay/?p=129) - Scott Wlaschin
- [caniemail.com](https://www.caniemail.com/) - Truth source for email client compatibility
