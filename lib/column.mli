(** Column component for multi-column email layouts.

    Columns are the building blocks of email layouts, using nested tables
    for Outlook Desktop compatibility. They support both pixel and percentage
    widths, along with vertical alignment options.

    The nested table structure is required because:
    - Outlook Desktop 2007-2024 only respects widths on table cells
    - Modern clients support div-based layouts but tables provide fallback
    - This approach ensures consistent rendering across all major clients

    caniemail reference:
    - https://www.caniemail.com/features/css-column-layout-properties/

    Example:
    {[
      let col = Column.v
        ~width:200
        ~vertical_align:"top"
        [Heading.h2 "Column 1"; Paragraph.v "Content"]
    ]}
*)

type t = private {
  width: int option;  (** Column width in pixels or percentage *)
  vertical_align: string option;  (** Vertical alignment: top, middle, bottom *)
  children: Element.t list;
}

(** Variant constructor for common case - no width specified *)
val v :
  ?width:int ->
  ?vertical_align:string ->
  Element.t list ->
  t

(** Full constructor with explicit unit parameter for optional arguments *)
val make :
  ?width:int ->
  ?vertical_align:string ->
  children:Element.t list ->
  unit ->
  t

(** Convert to Element.t for rendering *)
val to_element : t -> Element.t
