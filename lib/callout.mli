(** Callout component: tinted block with optional left-border accent,
    for quotes, tips, warnings, and info panels.

    Unlike a plain Section, a Callout communicates semantic weight and
    supports a colored left-border accent implemented via a two-column
    table (so it works in Outlook, which ignores CSS `border-left`).

    ⚠️ Known limitation: Border width is limited to 8px maximum in
    Outlook 2007-2021 and AOL clients. The default 4px accent width is
    safe across all clients. Borders are applied to table cells (not div/p)
    because they are unreliable on block elements in some Outlook versions.

    caniemail references:
    - https://www.caniemail.com/features/css-border/
      (covers border-left, border-right, and all side-specific properties;
       the two-column-table strategy used here is universally safe.)

    Example:
    {[
      Callout.v
        ~background:(Color.solid "#f3f0ff")
        ~accent:(Color.solid "#6b46c1")
        [ Paragraph.to_element (Paragraph.v "\"Looking forward to working with you.\"") ]
    ]}
*)

type t

val v :
  ?accent:Color.t ->
  ?padding:Spacing.t ->
  background:Color.t ->
  Element.t list ->
  t

val make :
  ?background:Color.t ->
  ?accent:Color.t ->
  ?padding:Spacing.t ->
  children:Element.t list ->
  unit ->
  t
(** At least one of [background] or [accent] must be provided — a
    Callout with neither is just a Section; use Section directly.

    @raise Invalid_argument if both [background] and [accent] are [None]. *)

val to_element : t -> Element.t
(** Convert to Element.t for rendering *)
