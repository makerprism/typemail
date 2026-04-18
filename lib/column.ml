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

  (* Wrap children in <tr><td> so block elements like <h1>, <p>, <img>
     are not direct children of <table> (which is invalid HTML and
     Outlook drops the orphaned nodes). *)
  let inner_td =
    Element.Private.make @@ Element.Private.builder
      ~tag:"td"
      ~attributes:[]
      ~children:column.children
  in
  let inner_tr =
    Element.Private.make @@ Element.Private.builder
      ~tag:"tr"
      ~attributes:[]
      ~children:[inner_td]
  in
  let table = Element.Private.make @@ Element.Private.builder
    ~tag:"table"
    ~attributes:[
      "border", "0";
      "cellpadding", "0";
      "cellspacing", "0";
      "role", "presentation";
    ]
    ~children:[inner_tr]
  in

  Element.Private.make @@ Element.Private.builder
    ~tag:"td"
    ~attributes:td_attributes
    ~children:[table]
