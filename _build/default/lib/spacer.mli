(** Vertical spacing component.

    Spacers create transparent vertical space between elements.
    This is safer than using CSS margins because Outlook Desktop
    ignores margin properties on many elements.

    The implementation uses a table-based approach which works
    consistently across all email clients including Outlook.

    caniemail references:
    - https://www.caniemail.com/features/css-padding/
    - https://www.caniemail.com/features/css-height/

    Example:
    {[
      let spacer = Spacer.v ~height:(Spacing.of_px_exn 32)
    ]}
*)

type t = private {
  height: Spacing.t;
}

(** Create a vertical spacer.

    @param height Height in pixels (defaults to 16px)
*)
val v :
  ?height:Spacing.t ->
  unit ->
  t

(** Convert to Element.t for rendering *)
val to_element : t -> Element.t
