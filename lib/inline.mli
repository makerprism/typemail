(** Inline text formatting for rich text content.

    This module provides inline formatting elements that can be composed
    to create rich text content with bold, italic, links, and code.

    All text content is HTML-escaped to prevent XSS. The API is designed
    to make unsafe patterns impossible: there is no way to inject raw HTML.

    Inline elements can be used in any context that accepts rich text:
    - Paragraph (body text)
    - Heading (titles)
    - List items (bullet points)
    - Table cells (data display)

    caniemail references:
    - https://www.caniemail.com/features/html-a-href/ (links: 100% supported)
    - https://www.caniemail.com/features/html-strong/ (bold: 100% supported)
    - https://www.caniemail.com/features/html-em/ (italic: 100% supported)
    - https://www.caniemail.com/features/html-code/ (code: 98% supported)

    Example:
    {[
      (* Compose inline content naturally *)
      let content = [
        Inline.v "Hello ";
        Inline.bold (Inline.v "world");
        Inline.v "! Visit ";
        Inline.link ~href:"https://example.com" (Inline.v "our site");
      ]

      (* Use in any context *)
      let paragraph = Paragraph.of_children content
    ]}
*)

(** [t] represents a single inline element - text, bold, italic, link, or code.

    The type is recursive to allow nesting (e.g., bold within a link).
    The constructors are private to prevent direct manipulation; use the
    provided smart constructors to build values.
*)
type t

(** Plain text - HTML-escaped. Use [v] as the smart constructor. *)
val v : string -> t

(** Bold text using <strong> tag. Accepts plain text or nested inline. *)
val bold : t -> t

(** Italic text using <em> tag. Accepts plain text or nested inline. *)
val italic : t -> t

(** Hyperlink with href and content. Content can be text or nested inline. *)
val link : href:string -> t -> t

(** Code span with monospace font and gray background.
    Universally supported except minor styling variance in Outlook 2013.

    Content should be plain text for code display.
*)
val code : string -> t

(** Colored span with optional color.
    Use sparingly - colored text has reduced accessibility.

    caniemail reference:
    - https://www.caniemail.com/features/html-span/ (100% supported)
*)
val span : ?color:Color.t -> string -> t

(** Convert a list of inline elements to Element.t list for rendering.

    This is the primary way to use inline content in components. Empty list
    produces no elements. Each inline element maps to one or more Element.t
    values (e.g., nested structures).
*)
val to_elements : t list -> Element.t list

(** Convert inline content to HTML string.
    Useful for testing and debugging.
*)
val to_html : t list -> string

(** Calculate size in bytes for Gmail limit checking.
    Counts the bytes of the rendered HTML including tags.
*)
val size_in_bytes : t list -> int
