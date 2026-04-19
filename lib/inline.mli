(** Inline text formatting for rich text within Paragraph and Heading.

    This module provides inline formatting elements that can be composed
    to create rich text content with bold, italic, and links.

    All text content is HTML-escaped to prevent XSS. The API is designed
    to make unsafe patterns impossible: there is no way to inject raw HTML.

    caniemail references:
    - https://www.caniemail.com/features/html-a-href/
    - https://www.caniemail.com/features/html-strong/
    - https://www.caniemail.com/features/html-em/

    Example:
    {[
      let content = Inline.concat [
        Inline.text "Hello ";
        Inline.bold "world";
        Inline.text "! Visit ";
        Inline.link ~href:"https://example.com" "our site";
      ]
      let paragraph = Paragraph.of_inline content
    ]}
*)

(** Inline content type.

    This type is recursive to allow nesting (e.g., bold within a link).
    The constructors are private to prevent direct manipulation; use the
    provided functions to construct values.
*)
type t =
  | Text of string
  | Bold of t
  | Italic of t
  | Link of {href: string; content: t}
  | Concat of t list

(** Plain text - HTML-escaped *)
val text : string -> t

(** Bold text using <strong> tag *)
val bold : string -> t

(** Italic text using <em> tag *)
val italic : string -> t

(** Hyperlink with href and link text *)
val link : href:string -> string -> t

(** Compose multiple inline elements into a single inline value.
    This is useful when you need mixed formatting in a single paragraph.

    Empty list produces empty text. Single-element lists return that element.
    Multiple elements are combined into a Concat node.
*)
val concat : t list -> t

(** Convert inline content to Element.t children.
    Returns a list of Element.t values that can be used as children.

    This function is primarily used by Paragraph and Heading components
    to render inline content.
*)
val to_elements : t -> Element.t list

(** Convert inline content to HTML string.
    Useful for testing and debugging.
*)
val to_html : t -> string

(** Calculate size in bytes for Gmail limit checking.
    Counts the bytes of the rendered HTML including tags.
*)
val size_in_bytes : t -> int
