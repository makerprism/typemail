(** Section component with table-based layout for Outlook compatibility.

    Sections are container components that group related content together.
    They use nested table structure to ensure consistent rendering across
    all email clients, including Outlook Desktop which requires tables
    for proper layout.

    Background colors and gradients are supported with automatic fallback
    handling - gradients will degrade to solid colors in Outlook Desktop.

    ⚠️ Known limitation: In some Outlook versions, vertical padding is
    uniform across all cells in the same row, adopting the largest value.
    This Section component uses padding on table cells (not div/p), which
    is required for cross-client compatibility.

    Padding can be specified uniformly via [~padding], or per-axis via
    [~padding_x] (left/right) and [~padding_y] (top/bottom). When both
    the uniform and an axis-specific value are provided, the axis-specific
    value wins for that axis.

    caniemail references:
    - https://www.caniemail.com/features/css-linear-gradient/
    - https://www.caniemail.com/features/css-padding/

    Example:
    {[
      Section.make
        ~background:(Color.solid "#f3f4f6")
        ~padding_y:(Spacing.of_px_exn 32)
        ~padding_x:(Spacing.of_px_exn 40)
        ~children:[
          Heading.to_element (Heading.h1 "Welcome");
          Paragraph.to_element (Paragraph.v "Content here");
        ]
        ()
    ]}
*)

type t = private {
  background: Color.t option;
  padding: Spacing.t option;
  padding_x: Spacing.t option;
  padding_y: Spacing.t option;
  children: Element.t list;
}

(** Smart constructor for common case - no background or padding *)
val v : Element.t list -> t

(** Constructor with optional background and padding.

    @param background Optional background color or gradient (with fallback)
    @param padding Optional uniform padding on all four sides
    @param padding_x Optional horizontal padding (left and right); overrides [padding] on the x-axis
    @param padding_y Optional vertical padding (top and bottom); overrides [padding] on the y-axis
    @param children List of child elements
*)
val make :
  ?background:Color.t ->
  ?padding:Spacing.t ->
  ?padding_x:Spacing.t ->
  ?padding_y:Spacing.t ->
  children:Element.t list ->
  unit ->
  t

(** Convert to Element.t for rendering *)
val to_element : t -> Element.t
