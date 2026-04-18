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

    caniemail reference:
    - https://www.caniemail.com/features/html-h1-h6/

    Example:
    {[
      Heading.h1 ~color:Color.Brand.white "You're invited"
      Heading.make
        ~level:H2
        ~text_align:Text_align.Center
        ~content:"Welcome!"
        ()
    ]}
*)

type level = H1 | H2 | H3 | H4 | H5 | H6

type t = private {
  level: level;
  color: Color.t option;
  font_size: Font_size.t option;
  text_align: Text_align.t option;
  content: string;
}

(** Smart constructors for each heading level.

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

(** General constructor with explicit level *)
val make :
  ?color:Color.t ->
  ?font_size:Font_size.t ->
  ?text_align:Text_align.t ->
  level:level ->
  content:string ->
  unit ->
  t

(** Convert to Element.t for rendering *)
val to_element : t -> Element.t

(** Get heading tag as string ("h1", "h2", etc.) *)
val tag : t -> string
