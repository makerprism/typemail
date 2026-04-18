(** Color values with cross-client fallback enforcement.

    All gradient colors must include a solid fallback color for Outlook
    compatibility. This is enforced at the type level - the gradient
    constructor requires a fallback field.

    caniemail references:
    - https://www.caniemail.com/features/css-linear-gradient/
    - https://www.caniemail.com/features/email-background-gradient/
*)

type t =
  | Solid of string
  | Gradient of {
      direction: string;
      colors: string list;
      fallback: t;  (** Required solid color for Outlook *)
    }

(** Smart constructors for common brand colors *)
module Brand : sig
  val indigo_900 : t
  val indigo_600 : t
  val white : t
  val black : t
  val gray_100 : t
  val gray_200 : t
  val gray_300 : t
  val gray_400 : t
  val gray_500 : t
end

(** Construct a solid color from hex string *)
val solid : string -> t

(** Construct a gradient with required fallback.

    @param direction CSS gradient direction (e.g. "to right", "to bottom")
    @param colors List of hex color stops
    @param fallback Solid color for Outlook (must be Solid, not Gradient)
*)
val gradient :
  direction:string ->
  colors:string list ->
  fallback:t ->
  t

(** Extract the fallback color from any color *)
val fallback : t -> t

(** Convert to CSS value *)
val to_css : t -> string

(** Convert to inline style attribute value *)
val to_style : t -> string
