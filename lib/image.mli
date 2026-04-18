(** Image component with accessibility-first design.

    Images require alt text for accessibility - there is NO way to construct
    an image without providing alt text. This is enforced at the type level.

    Width and height can be specified for better rendering performance and
    to prevent layout shift. Border radius is optional for rounded corners.

    caniemail references:
    - https://www.caniemail.com/features/html-img/
    - https://www.caniemail.com/features/css-width/

    Example:
    {[
      Image.v
        ~src:"https://example.com/logo.png"
        ~alt:"Company Logo"
        ~width_px:200
        ~height_px:50
    ]}
*)

type t = private {
  src: string;
  alt: string;  (** REQUIRED - accessibility, enforced by type system *)
  width_px: int option;
  height_px: int option;
  border_radius: int option;
}

(** Variant constructor for common case - no border radius.
    Requires src, alt, and dimensions for layout stability.
*)
val v :
  src:string ->
  alt:string ->
  width_px:int ->
  height_px:int ->
  t

(** Full constructor with optional dimensions and border radius.
    Alt text is still required - no constructor exists without it.
*)
val make :
  ?width_px:int ->
  ?height_px:int ->
  ?border_radius:int ->
  src:string ->
  alt:string ->
  unit ->
  t

(** Convert to Element.t for rendering *)
val to_element : t -> Element.t
