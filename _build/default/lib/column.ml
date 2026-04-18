(** Column component for multi-column email layouts. *)

type t = {
  width: int option;
  vertical_align: string option;
  children: Element.t list;
}

let v ?width ?vertical_align children =
  {width; vertical_align; children}

let make ?width ?vertical_align ~children () =
  {width; vertical_align; children}

let to_element column =
  (* Create table cell with width and vertical alignment *)
  let td_attributes = [
    "valign", Option.value ~default:"middle" column.vertical_align;
  ] in
  let td_attributes = match column.width with
    | None -> td_attributes
    | Some w -> ("width", string_of_int w) :: td_attributes
  in

  (* Wrap in table for Outlook compatibility *)
  let table = Element.Private.make @@ Element.Private.builder
    ~tag:"table"
    ~attributes:[
      "border", "0";
      "cellpadding", "0";
      "cellspacing", "0";
      "role", "presentation";
    ]
    ~children:column.children
  in

  Element.Private.make @@ Element.Private.builder
    ~tag:"td"
    ~attributes:td_attributes
    ~children:[table]
