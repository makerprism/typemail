(** Decorative Icon component - emoji (or short unicode) centered in an
    optional colored/gradient circle.

    Use for decorative visual accents (a user icon above a "You're
    invited!" heading, a warning triangle above an error message).
    Explicitly not for interactive or semantic icons - those should be
    real [Image]s with alt text.

    The circular bubble uses CSS [border-radius: 50%] on a fixed-size
    [<td>]. Outlook Desktop ignores [border-radius] and degrades to a
    square, which is visually acceptable for decorative elements.

    caniemail references:
    - https://www.caniemail.com/features/css-border-radius/ (graceful
      degradation on Outlook)

    Example:
    {[
      Icon.v
        ~background:(Color.gradient
          ~direction:"135deg"
          ~colors:["#7c3aed"; "#6b46c1"]
          ~fallback:(Color.solid "#6b46c1"))
        ~diameter_px:80
        ~size_px:40
        "👥"
    ]}
*)

type t = private {
  content: string;
  background: Color.t option;
  diameter_px: int option;
  size_px: int;
}

(** Smart constructor. [diameter_px] defaults to [size_px * 2] when a
    [background] is provided and [diameter_px] is omitted. *)
val v :
  ?background:Color.t ->
  ?diameter_px:int ->
  size_px:int ->
  string ->
  t

(** Full constructor with explicit unit parameter. *)
val make :
  ?background:Color.t ->
  ?diameter_px:int ->
  size_px:int ->
  content:string ->
  unit ->
  t

(** Convert to Element.t for rendering *)
val to_element : t -> Element.t
