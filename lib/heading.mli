(** Heading component with level for accessibility.

    Headings are distinct from Paragraph components so screen readers
    can properly distinguish document structure. The level is enforced
    at compile time - you cannot silently downgrade a Heading to a Text
    node (unlike MJML).

    ⚠️ Known limitation: Some webmail clients (notably Orange 2021-08+)
    override default h1/h2 styling with their own colors (h1→#fff,
    h2→#354963). Consider this when designing color-critical headings.

    Italic styling is intentionally not exposed for headings: italic
    headings are unusual in transactional email. Authors that need one
    should compose a Paragraph with [Font_style.Italic] instead.

    All optional style fields (color, font_size, text_align) are combined
    into a single inline [style] attribute at render time.

    Headings support both plain text and rich inline formatting (bold,
    italic, links) via the Inline module. Use [h1], [h2], etc. for plain
    text or [of_inline] for rich content.

    caniemail reference:
    - https://www.caniemail.com/features/html-h1-h6/

    Example:
    {[
      (* Plain text heading *)
      Heading.h1 ~color:Color.Brand.white "You're invited"

      (* Rich text heading with inline formatting *)
      Heading.of_inline_h1 @@ Inline.concat [
        Inline.text "Welcome ";
        Inline.bold "home";
      ]
    ]}
*)

type level = H1 | H2 | H3 | H4 | H5 | H6

type t = private {
  level: level;
  color: Color.t option;
  font_size: Font_size.t option;
  text_align: Text_align.t option;
  content: content;
}

(** Content type - either plain text or rich inline formatting *)
and content =
  | Text of string
  | Inline of Inline.t

(** Smart constructors for each heading level with plain text.

    @param color Optional text color
    @param font_size Optional font size
    @param text_align Optional text alignment
    @param content Heading text content (will be HTML-escaped)
*)
val h1 :
  ?color:Color.t ->
  ?font_size:Font_size.t ->
  ?text_align:Text_align.t ->
  string ->
  t
val h2 :
  ?color:Color.t ->
  ?font_size:Font_size.t ->
  ?text_align:Text_align.t ->
  string ->
  t
val h3 :
  ?color:Color.t ->
  ?font_size:Font_size.t ->
  ?text_align:Text_align.t ->
  string ->
  t
val h4 :
  ?color:Color.t ->
  ?font_size:Font_size.t ->
  ?text_align:Text_align.t ->
  string ->
  t
val h5 :
  ?color:Color.t ->
  ?font_size:Font_size.t ->
  ?text_align:Text_align.t ->
  string ->
  t
val h6 :
  ?color:Color.t ->
  ?font_size:Font_size.t ->
  ?text_align:Text_align.t ->
  string ->
  t

(** Smart constructors for each heading level with rich inline formatting.

    @param color Optional text color
    @param font_size Optional font size
    @param text_align Optional text alignment
    @param inline Heading inline content from the Inline module
*)
val of_inline_h1 :
  ?color:Color.t ->
  ?font_size:Font_size.t ->
  ?text_align:Text_align.t ->
  Inline.t ->
  t
val of_inline_h2 :
  ?color:Color.t ->
  ?font_size:Font_size.t ->
  ?text_align:Text_align.t ->
  Inline.t ->
  t
val of_inline_h3 :
  ?color:Color.t ->
  ?font_size:Font_size.t ->
  ?text_align:Text_align.t ->
  Inline.t ->
  t
val of_inline_h4 :
  ?color:Color.t ->
  ?font_size:Font_size.t ->
  ?text_align:Text_align.t ->
  Inline.t ->
  t
val of_inline_h5 :
  ?color:Color.t ->
  ?font_size:Font_size.t ->
  ?text_align:Text_align.t ->
  Inline.t ->
  t
val of_inline_h6 :
  ?color:Color.t ->
  ?font_size:Font_size.t ->
  ?text_align:Text_align.t ->
  Inline.t ->
  t

(** General constructor with explicit level and plain text content.
    For rich text formatting, use [of_inline] instead.
*)
val make :
  ?color:Color.t ->
  ?font_size:Font_size.t ->
  ?text_align:Text_align.t ->
  level:level ->
  content:string ->
  unit ->
  t

(** General constructor with explicit level and rich inline content.
    Use Inline.concat to combine multiple inline elements.
*)
val of_inline :
  ?color:Color.t ->
  ?font_size:Font_size.t ->
  ?text_align:Text_align.t ->
  level:level ->
  Inline.t ->
  t

(** Convert to Element.t for rendering *)
val to_element : t -> Element.t

(** Get heading tag as string ("h1", "h2", etc.") *)
val tag : t -> string
