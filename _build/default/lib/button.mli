(** Button component with Outlook-safe dimensions.

    Buttons require explicit pixel width and height because Outlook Desktop
    2007-2024 ignores CSS sizing and requires inline dimensions on VML
    elements. This is enforced at the type level - there is no way to
    construct a button without specifying width_px and height_px.

    caniemail references:
    - https://www.caniemail.com/features/email-button-padding/
    - https://www.caniemail.com/features/email-background-gradient/

    Example:
    {[
      Button.v
        ~href:"https://example.com"
        ~background:(Color.Solid Color.Brand.indigo_600)
        ~text_color:Color.Brand.white
        ~width_px:200
        ~height_px:44
        "Click me"
    ]}
*)

type t = private {
  href: string;
  background: Color.t;
  text_color: Color.t;
  width_px: int;
  height_px: int;
  border_radius: int option;
  content: string;
}

(** Variant constructor for common case - no border radius *)
val v :
  href:string ->
  background:Color.t ->
  text_color:Color.t ->
  width_px:int ->
  height_px:int ->
  string ->
  t

(** Full constructor with optional border radius *)
val make :
  ?border_radius:int option ->
  href:string ->
  background:Color.t ->
  text_color:Color.t ->
  width_px:int ->
  height_px:int ->
  content:string ->
  unit ->
  t

(** Convert to Element.t for rendering *)
val to_element : t -> Element.t
