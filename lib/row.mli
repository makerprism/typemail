(** Row component — lays [Column]s side-by-side as siblings in a single
    [<tr>]. This is the correct container for multi-column layouts;
    putting [Column]s directly as [Section] children produces nested
    [<td>] which is invalid HTML and causes cross-client layout drift.

    Row is a sibling component to Section — use Section for vertical
    stacking (its children are [Element.t]), and Row for horizontal
    stacking (its children are [Column.t], enforced at the type level).

    caniemail reference:
    - https://www.caniemail.com/features/html-table/
      (HTML tables are the only reliable cross-client method for side-by-side
       column layouts; CSS column properties have partial support and are
       unsafe for Outlook compatibility.)

    Example:
    {[
      Section.make
        ~background:Color.Brand.white
        ~padding_y:(Spacing.of_px_exn 32)
        ~padding_x:(Spacing.of_px_exn 40)
        ~children:[
          Row.to_element (Row.of_columns [
            Column.v ~width:52 [logo];
            Column.v [heading; tagline];
          ])
        ]
        ()
    ]}
*)

type t

(** Smart constructor for the common case. *)
val of_columns : Column.t list -> t

(** Full constructor with explicit unit parameter. *)
val make : columns:Column.t list -> unit -> t

(** Convert to Element.t for rendering *)
val to_element : t -> Element.t
