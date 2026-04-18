(** Footer component with optional background color.

    Footers are commonly used for unsubscribe links, postal addresses,
    and copyright notices. This component provides a simple text-based
    footer with optional background color using table-based structure
    for Outlook compatibility.

    For more complex footers with multiple elements, compose them
    using other components and wrap in a container.

    caniemail references:
    - https://www.caniemail.com/features/css-text-align/
    - https://www.caniemail.com/features/css-padding/

    Example:
    {[
      let footer = Footer.v ~background:(Color.solid "#1f2937") "© 2024 Company"
    ]}
*)

type t = private {
  background: Color.t option;
  content: string;
}

(** Variant constructor for common case.

    @param background Optional background color
    @param content Text content for the footer
*)
val v :
  ?background:Color.t ->
  string ->
  t

(** Full constructor with explicit unit parameter.

    @param background Optional background color
    @param content Text content for the footer
*)
val make :
  ?background:Color.t ->
  content:string ->
  unit ->
  t

(** Convert to Element.t for rendering *)
val to_element : t -> Element.t
