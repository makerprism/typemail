(** Decorative Icon component - emoji (or short unicode) centered in an
    optional colored/gradient circle. *)

type t = {
  content: string;
  background: Color.t option;
  diameter_px: int option;
  size_px: int;
}

let validate_args ~where ~content ~size_px ~diameter_px =
  if content = "" then
    invalid_arg (where ^ ": content cannot be empty");
  if size_px <= 0 then
    invalid_arg (where ^ ": size_px must be > 0");
  match diameter_px with
  | Some d when d <= 0 ->
      invalid_arg (where ^ ": diameter_px must be > 0")
  | _ -> ()

let v ?background ?diameter_px ~size_px content =
  validate_args ~where:"Icon.v" ~content ~size_px ~diameter_px;
  {content; background; diameter_px; size_px}

let make ?background ?diameter_px ~size_px ~content () =
  validate_args ~where:"Icon.make" ~content ~size_px ~diameter_px;
  {content; background; diameter_px; size_px}

(* Outer wrapper: full-width centering table. Single source for both
   bubble and plain-glyph render paths. *)
let center_wrapper ~inner =
  Element.Private.make @@ Element.Private.builder
    ~tag:"table"
    ~attributes:[
      "border", "0";
      "cellpadding", "0";
      "cellspacing", "0";
      "role", "presentation";
      "width", "100%";
    ]
    ~children:[Element.Private.make @@ Element.Private.builder
      ~tag:"tr"
      ~attributes:[]
      ~children:[Element.Private.make @@ Element.Private.builder
        ~tag:"td"
        ~attributes:["align", "center"]
        ~children:[inner]
      ]
    ]

let glyph_only_table ~size_px ~content =
  let td = Element.Private.make @@ Element.Private.builder
    ~tag:"td"
    ~attributes:[
      "align", "center";
      "style",
        Printf.sprintf "font-size: %dpx; line-height: 1;" size_px;
    ]
    ~children:[Element.text content]
  in
  let tr = Element.Private.make @@ Element.Private.builder
    ~tag:"tr" ~attributes:[] ~children:[td]
  in
  Element.Private.make @@ Element.Private.builder
    ~tag:"table"
    ~attributes:[
      "border", "0";
      "cellpadding", "0";
      "cellspacing", "0";
      "role", "presentation";
    ]
    ~children:[tr]

let bubble_table ~size_px ~diameter ~background ~content =
  let bg_fallback_hex = Color.(background |> fallback |> to_css) in
  let bg_style = Color.to_style background in
  let style =
    Printf.sprintf
      "width: %dpx; height: %dpx; %s border-radius: 50%%; \
       font-size: %dpx; line-height: %dpx; text-align: center;"
      diameter diameter bg_style size_px diameter
  in
  let td = Element.Private.make @@ Element.Private.builder
    ~tag:"td"
    ~attributes:[
      "width", string_of_int diameter;
      "height", string_of_int diameter;
      "align", "center";
      "valign", "middle";
      "bgcolor", bg_fallback_hex;
      "style", style;
    ]
    ~children:[Element.text content]
  in
  let tr = Element.Private.make @@ Element.Private.builder
    ~tag:"tr" ~attributes:[] ~children:[td]
  in
  Element.Private.make @@ Element.Private.builder
    ~tag:"table"
    ~attributes:[
      "border", "0";
      "cellpadding", "0";
      "cellspacing", "0";
      "role", "presentation";
    ]
    ~children:[tr]

let to_element icon =
  let inner = match icon.background with
    | None ->
        glyph_only_table ~size_px:icon.size_px ~content:icon.content
    | Some background ->
        let diameter = match icon.diameter_px with
          | Some d -> d
          | None -> icon.size_px * 2
        in
        bubble_table
          ~size_px:icon.size_px ~diameter ~background ~content:icon.content
  in
  center_wrapper ~inner
