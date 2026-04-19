(** Paragraph component for body text.

    Paragraphs are distinct from Heading components so screen readers
    can properly distinguish document structure. This is critical for
    accessibility - unlike MJML where `<mj-text>` is used for both.

    All optional style fields (color, font_size, font_style, text_align)
    are combined into a single inline [style] attribute at render time,
    which is the only cross-client reliable way to apply text styling.

    Paragraphs support both plain text and rich text with inline formatting:

    {v[
      (* Plain text - simple and common *)
      Paragraph.v "This is a paragraph of text."

      (* Rich text - with inline formatting *)
      Paragraph.make ~children:[
        Inline.Text.v "Join ";
        Inline.Bold.v "Team";
        Inline.Text.v " ";
        Inline.(link ~href:"https://example.com" (v "now!"));
      ] ()

      (* Styled paragraph with rich text *)
      Paragraph.make
        ~color:Color.Brand.gray_500
        ~font_size:Font_size.small
        ~children:[
          Inline.Text.v "Fine print with ";
          Inline.Italic.v "emphasis";
        ]
        ()
    ]}

    caniemail references:
    - https://www.caniemail.com/features/css-text-align/
    - https://www.caniemail.com/features/css-font-size/
    - https://www.caniemail.com/features/css-font/
*)

type t

(** Smart constructor for common case - plain text, no styling specified.

    @param content Plain text content (will be HTML-escaped)
*)
val v : string -> t

(** Build a paragraph from rich text inline elements.

    Use this when the paragraph needs inline formatting like bold, italic,
    links, or colored text. The inline elements are rendered in order inside
    the paragraph.

    @param color Optional text color
    @param font_size Optional font size
    @param font_style Optional font style
    @param text_align Optional text alignment
    @param children Rich text inline elements
*)
val of_children :
  ?color:Color.t ->
  ?font_size:Font_size.t ->
  ?font_style:Font_style.t ->
  ?text_align:Text_align.t ->
  Inline.t list ->
  t

(** Full constructor accepting either plain text or rich inline elements.

    At least one of [content] or [children] must be provided. When both
    are given, [children] wins; the text body is ignored. Passing neither
    raises [Invalid_argument].

    Use [content] for simple plain text paragraphs.
    Use [children] for paragraphs with inline formatting.

    @param color Optional text color
    @param font_size Optional font size
    @param font_style Optional font style
    @param text_align Optional text alignment
    @param content Plain text content (used when [children] is absent)
    @param children Rich text inline elements (takes precedence over [content])
*)
val make :
  ?color:Color.t ->
  ?font_size:Font_size.t ->
  ?font_style:Font_style.t ->
  ?text_align:Text_align.t ->
  ?content:string ->
  ?children:Inline.t list ->
  unit ->
  t

(** Convert to Element.t for rendering *)
val to_element : t -> Element.t
