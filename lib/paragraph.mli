(** Paragraph component for body text.

    Paragraphs are distinct from Heading components so screen readers
    can properly distinguish document structure. This is critical for
    accessibility - unlike MJML where `<mj-text>` is used for both.

    All optional style fields (color, font_size, font_style, text_align)
    are combined into a single inline [style] attribute at render time,
    which is the only cross-client reliable way to apply text styling.

    Paragraphs support both plain text and rich inline formatting (bold,
    italic, links, code) via the Inline module. Use [v] for plain text
    or [of_children] for rich content.

    caniemail references:
    - https://www.caniemail.com/features/css-text-align/
    - https://www.caniemail.com/features/css-font-size/
    - https://www.caniemail.com/features/css-font/
    - https://www.caniemail.com/features/html-strong/ (100% supported)

    Note: Inline formatting uses <strong>, <em>, <code>, and <a> tags
    which are basic HTML elements with universal email client support.

    Example:
    {[
      (* Plain text paragraph *)
      Paragraph.v "This is a paragraph of text."

      (* Styled paragraph *)
      Paragraph.make
        ~color:Color.Brand.gray_500
        ~font_size:Font_size.small
        ~content:"Fine print."
        ()

      (* Rich text with inline formatting *)
      Paragraph.of_children [
        Inline.v "Welcome ";
        Inline.bold (Inline.v "new user");
        Inline.v "! ";
        Inline.link ~href:"https://example.com" (Inline.v "Get started");
      ]
    ]}
*)

type t = private {
  content: content;
  color: Color.t option;
  font_size: Font_size.t option;
  font_style: Font_style.t option;
  text_align: Text_align.t option;
}

(** Content type - either plain text or rich inline formatting *)
and content =
  | Text of string
  | Inline of Inline.t list

(** Smart constructor for common case - plain text, no styling specified *)
val v : string -> t

(** Constructor for rich inline formatting with optional styling.
    Accepts a list of inline elements for mixed formatting.

    @param children Rich inline content from the Inline module
*)
val of_children :
  ?color:Color.t ->
  ?font_size:Font_size.t ->
  ?font_style:Font_style.t ->
  ?text_align:Text_align.t ->
  Inline.t list ->
  t

(** Constructor with optional styling fields.
    For plain text content. Use [of_children] for rich text formatting.

    @param content Plain text content
*)
val make :
  ?color:Color.t ->
  ?font_size:Font_size.t ->
  ?font_style:Font_style.t ->
  ?text_align:Text_align.t ->
  content:string ->
  unit ->
  t

(** Convert to Element.t for rendering *)
val to_element : t -> Element.t
