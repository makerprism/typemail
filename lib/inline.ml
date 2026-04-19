(** Inline text formatting elements for rich text content.

    This module provides type-safe inline formatting components that can be
    used within Paragraph and Heading components to add emphasis, links, and
    other text styling.

    All inline elements are rendered as HTML with proper escaping and
    cross-client compatibility. See caniemail references for each element.

    Example:
    {[
      Paragraph.make ~children:[
        Inline.Text.v "Join ";
        Inline.Bold.v "Team";
        Inline.Text.v "!";
      ] ()
    ]}
*)

(** Type of inline text elements.

    This type is abstract to prevent raw HTML injection. All inline elements
    must be constructed through the provided smart constructors.
*)
type t =
  | Text of string
  | Bold of t
  | Italic of t
  | Link of {href: string; children: t}
  | Code of string
  | Span of {color: Color.t option; children: t}

let rec to_element = function
  | Text content ->
      Element.text content
  | Bold child ->
      let child_elem = to_element child in
      Element.Private.make @@ Element.Private.builder
        ~tag:"strong"
        ~attributes:[]
        ~children:[child_elem]
  | Italic child ->
      let child_elem = to_element child in
      Element.Private.make @@ Element.Private.builder
        ~tag:"em"
        ~attributes:[]
        ~children:[child_elem]
  | Link {href; children} ->
      let child_elem = to_element children in
      Element.Private.make @@ Element.Private.builder
        ~tag:"a"
        ~attributes:["href", href]
        ~children:[child_elem]
  | Code content ->
      Element.Private.make @@ Element.Private.builder
        ~tag:"code"
        ~attributes:["style", "background-color: #f3f4f6; padding: 2px 4px; border-radius: 3px; font-family: monospace;"]
        ~children:[Element.text content]
  | Span {color; children} ->
      let child_elem = to_element children in
      let attributes = match color with
        | None -> []
        | Some c -> ["style", Printf.sprintf "color: %s;" (Color.to_css c)]
      in
      Element.Private.make @@ Element.Private.builder
        ~tag:"span"
        ~attributes
        ~children:[child_elem]

(** Text content - plain text without formatting *)
let v content = Text content

(** Bold text - renders as <strong>

    caniemail reference:
    - https://www.caniemail.com/features/html-strong/
*)
let bold child = Bold child

(** Italic text - renders as <em>

    caniemail reference:
    - https://www.caniemail.com/features/html-em/
*)
let italic child = Italic child

(** Hyperlink - renders as <a>

    The [href] attribute is required for accessibility and usability.

    caniemail reference:
    - https://www.caniemail.com/features/html-a/
*)
let link ~href child = Link {href; children = child}

(** Inline code - renders as <code> with subtle background

    This is styled with a light gray background and monospace font
    for code snippets. Note that complex code formatting should use
    a preformatted text component instead.

    caniemail reference:
    - https://www.caniemail.com/features/html-code/
*)
let code content = Code content

(** Colored span - renders as <span> with inline color style

    Use this to apply color to a run of text without other formatting.

    caniemail reference:
    - https://www.caniemail.com/features/css-color/
*)
let span ?color child = Span {color; children = child}
