(** Footer section with optional background color. *)

type t = {
  background: Color.t option;
  content: string;
}

let v ?background content =
  {background; content}

let make ?background ~content () =
  {background; content}

let to_element footer =
  let td_attributes = match footer.background with
    | None -> []
    | Some color -> ["bgcolor", Color.(color |> fallback |> to_css)]
  in
  Element.Private.make @@ Element.Private.builder
    ~tag:"table"
    ~attributes:[
      "border", "0";
      "cellpadding", "0";
      "cellspacing", "0";
      "role", "presentation";
    ]
    ~children:[Element.Private.make @@ Element.Private.builder
      ~tag:"tr"
      ~attributes:[]
      ~children:[Element.Private.make @@ Element.Private.builder
        ~tag:"td"
        ~attributes:td_attributes
        ~children:[Element.text footer.content]
      ]
    ]
