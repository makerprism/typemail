(** Footer section with optional background color. *)

type content =
  | Text of string
  | Children of Element.t list

type t = {
  background: Color.t option;
  content: content;
}

let v ?background content =
  {background; content = Text content}

let of_children ?background children =
  {background; content = Children children}

(* [children] wins over [content] so callers migrating to the rich variant
   don't silently fall back to the text path when both are set. *)
let make ?background ?content ?children () =
  match children, content with
  | Some elts, _ -> {background; content = Children elts}
  | None, Some s -> {background; content = Text s}
  | None, None ->
    invalid_arg "Footer.make: at least one of ~content or ~children is required"

let to_element footer =
  let td_attributes = match footer.background with
    | None -> []
    | Some color -> ["bgcolor", Color.(color |> fallback |> to_css)]
  in
  let td_children = match footer.content with
    | Text s -> [Element.text s]
    | Children elts -> elts
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
        ~children:td_children
      ]
    ]
