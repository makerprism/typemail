(** Paragraph component for body text.

    Paragraphs are distinct from Heading components so screen readers
    can properly distinguish document structure. This is critical for
    accessibility - unlike MJML where `<mj-text>` is used for both.

    caniemail references:
    - https://www.caniemail.com/features/css-text-align/
    - https://www.caniemail.com/features/css-font-size/
    - https://www.caniemail.com/features/css-font/

    Example:
    {[
      Paragraph.v "This is a paragraph of text."
      Paragraph.v ~color:Color.Brand.gray_600 "This is gray text."
    ]}
*)

type t = private {
  content: string;
  color: Color.t option;
}

(** Smart constructor for common case - no color specified *)
val v : string -> t

(** Constructor with optional color *)
val make : ?color:Color.t -> content:string -> unit -> t

(** Convert to Element.t for rendering *)
val to_element : t -> Element.t
