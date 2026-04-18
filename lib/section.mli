(** Section component with table-based layout for Outlook compatibility.

    Sections are container components that group related content together.
    They use nested table structure to ensure consistent rendering across
    all email clients, including Outlook Desktop which requires tables
    for proper layout.

    Background colors and gradients are supported with automatic fallback
    handling - gradients will degrade to solid colors in Outlook Desktop.

    caniemail references:
    - https://www.caniemail.com/features/email-background-gradient/
    - https://www.caniemail.com/features/email-table-cell-padding/

    Example:
    {[
      Section.v
        ~background:(Color.solid "#f3f4f6")
        ~padding:(Spacing.of_px_exn 16)
        [Heading.h1 "Welcome"; Paragraph.v "Content here"]
    ]}
*)

type t = private {
  background: Color.t option;
  padding: Spacing.t option;
  children: Element.t list;
}

(** Smart constructor for common case - no background or padding *)
val v : Element.t list -> t

(** Constructor with optional background and padding

    @param background Optional background color or gradient (with fallback)
    @param padding Optional padding in pixels
    @param children List of child elements
*)
val make :
  ?background:Color.t ->
  ?padding:Spacing.t ->
  children:Element.t list ->
  unit ->
  t

(** Convert to Element.t for rendering *)
val to_element : t -> Element.t
