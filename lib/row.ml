(** Row component — lays [Column]s side-by-side inside a single [<tr>]. *)

type t = {
  columns: Column.t list;
}

let of_columns columns =
  {columns}

let make ~columns () =
  {columns}

let to_element row =
  (* Each Column.to_element emits a <td>; placing them as siblings inside
     one <tr> is what makes them render side-by-side. Wrapping that <tr>
     in the presentation table keeps the output parallel to Section's
     table/tr/td shape so a Row can drop into any Section child slot. *)
  let tds = List.map Column.to_element row.columns in
  let tr =
    Element.Private.make @@ Element.Private.builder
      ~tag:"tr"
      ~attributes:[]
      ~children:tds
  in
  Element.Private.make @@ Element.Private.builder
    ~tag:"table"
    ~attributes:[
      "border", "0";
      "cellpadding", "0";
      "cellspacing", "0";
      "role", "presentation";
      "width", "100%";
    ]
    ~children:[tr]
