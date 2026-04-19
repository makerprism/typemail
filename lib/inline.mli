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
type t

(** Text content - plain text without formatting.

    This is the most basic inline element, representing a run of plain text
    that will be HTML-escaped when rendered.
*)
val v : string -> t

(** Bold text - renders as <strong>

    Use [bold] to emphasize important text. The <strong> tag conveys
    semantic importance (not just visual weight).

    caniemail reference:
    - https://www.caniemail.com/features/html-strong/

    @param child The inline element to make bold
*)
val bold : t -> t

(** Italic text - renders as <em>

    Use [italic] for emphasized text. The <em> tag conveys stress emphasis
    (not just visual styling).

    caniemail reference:
    - https://www.caniemail.com/features/html-em/

    @param child The inline element to make italic
*)
val italic : t -> t

(** Hyperlink - renders as <a>

    Creates a clickable link. The [href] attribute is required for
    accessibility and usability.

    caniemail reference:
    - https://www.caniemail.com/features/html-a/

    @param href The URL to link to
    @param child The inline element(s) to wrap in the link (typically Text.v)
*)
val link : href:string -> t -> t

(** Inline code - renders as <code> with subtle background

    This is styled with a light gray background (#f3f4f6) and monospace
    font for code snippets. For multi-line code blocks, use a preformatted
    text component instead.

    caniemail reference:
    - https://www.caniemail.com/features/html-code/

    @param content The code text (will be HTML-escaped)
*)
val code : string -> t

(** Colored span - renders as <span> with inline color style

    Use this to apply color to a run of text without other formatting.
    When [color] is None, this renders as a plain <span> with no styling.

    caniemail reference:
    - https://www.caniemail.com/features/css-color/

    @param color Optional color to apply to the text
    @param child The inline element to wrap in a colored span
*)
val span : ?color:Color.t -> t -> t

(** Convert an inline element to an Element.t for rendering.

    This is used internally by Paragraph and Heading to render inline
    elements as HTML.
*)
val to_element : t -> Element.t
