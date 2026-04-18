(** Horizontal divider/separator line.

    Dividers use the `<hr>` tag with inline styles for maximum
    cross-client compatibility. The height controls the thickness
    of the line.

    caniemail reference:
    - https://www.caniemail.com/features/email-hr/

    Example:
    {[
      let divider = Divider.v ~color:(Color.solid "#e5e7eb") ()
    ]}
*)

type t = private {
  color: Color.t option;
  height: Spacing.t;
}

(** Smart constructor for common case - 1px height, default gray color

    @param color Optional color (defaults to #cccccc)
    @param height Optional height (defaults to 1px)
*)
val v : ?color:Color.t -> ?height:Spacing.t -> unit -> t

(** Full constructor with required height parameter

    @param color Optional color
    @param height Height in pixels (required)
*)
val make : ?color:Color.t -> height:Spacing.t -> unit -> t

(** Convert to Element.t for rendering *)
val to_element : t -> Element.t
