(** Paragraph component for body text.

    Paragraphs are distinct from Heading components so screen readers
    can properly distinguish document structure. This is critical for
    accessibility - unlike MJML where `<mj-text>` is used for both.

    All optional style fields (color, font_size, font_style, text_align)
    are combined into a single inline [style] attribute at render time,
    which is the only cross-client reliable way to apply text styling.

    caniemail references:
    - https://www.caniemail.com/features/css-text-align/
    - https://www.caniemail.com/features/css-font-size/
    - https://www.caniemail.com/features/css-font/

    Example:
    {[
      Paragraph.v "This is a paragraph of text."
      Paragraph.make
        ~color:Color.Brand.gray_500
        ~font_size:Font_size.small
        ~content:"Fine print."
        ()
    ]}
*)

type t = private {
  content: string;
  color: Color.t option;
  font_size: Font_size.t option;
  font_style: Font_style.t option;
  text_align: Text_align.t option;
}

(** Smart constructor for common case - no styling specified *)
val v : string -> t

(** Constructor with optional styling fields *)
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
