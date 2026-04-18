(** Footer component with optional background color.

    Footers are commonly used for unsubscribe links, postal addresses,
    and copyright notices. This component supports either a simple text
    body or a list of child elements (paragraphs, links, dividers) for
    richer layouts, while keeping the table-based structure required
    for Outlook compatibility.

    For more complex footers with multiple elements, use [of_children]
    to build a rich footer from arbitrary child elements.

    caniemail references:
    - https://www.caniemail.com/features/css-text-align/
    - https://www.caniemail.com/features/css-padding/

    Example:
    {[
      let simple =
        Footer.v ~background:(Color.solid "#1f2937") "© 2024 Company"

      let rich =
        Footer.of_children ~background:(Color.solid "#1f2937") [
          Paragraph.to_element (Paragraph.v "© 2024 Company");
          Paragraph.to_element (Paragraph.v "123 Example Street");
        ]
    ]}
*)

type t

(** Smart constructor for the common text-only case.

    @param background Optional background color
    @param content Text content for the footer
*)
val v :
  ?background:Color.t ->
  string ->
  t

(** Build a rich footer from a list of child elements.

    Use this when the footer needs multiple paragraphs, links, or a
    divider. The children are rendered in order inside the footer's
    table cell; the outer table/tr/td structure is unchanged.

    @param background Optional background color
*)
val of_children :
  ?background:Color.t ->
  Element.t list ->
  t

(** Full constructor accepting either a text body or child elements.

    At least one of [content] or [children] must be provided. When both
    are given, [children] wins; the text body is ignored. Passing
    neither raises [Invalid_argument].

    @param background Optional background color
    @param content Text body (used when [children] is absent)
    @param children Rich child elements (takes precedence over [content])
*)
val make :
  ?background:Color.t ->
  ?content:string ->
  ?children:Element.t list ->
  unit ->
  t

(** Convert to Element.t for rendering *)
val to_element : t -> Element.t
