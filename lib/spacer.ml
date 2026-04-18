(** Vertical spacing component. *)

type t = {
  height: Spacing.t;
}

let v ?(height = Spacing.Spacing.px16) () =
  {height}

let to_element spacer =
  (* Use table-based spacer for maximum Outlook compatibility *)
  let height_str = Spacing.to_css spacer.height in

  (* Create transparent table with fixed height *)
  Element.Private.make @@
    Element.Private.builder
      ~tag:"table"
      ~attributes:[
        "role", "presentation";
        "border", "0";
        "cellpadding", "0";
        "cellspacing", "0";
        "width", "100%";
      ]
      ~children:[
        Element.Private.make @@
          Element.Private.builder
            ~tag:"tr"
            ~attributes:[]
            ~children:[
              Element.Private.make @@
                Element.Private.builder
                  ~tag:"td"
                  ~attributes:[
                    "style", Printf.sprintf "height: %s; line-height: %s; font-size: %s;" height_str height_str height_str;
                  ]
                  ~children:[
                    Element.Private.make @@
                      Element.Private.builder
                        ~tag:"span"
                        ~attributes:[
                          "style", Printf.sprintf "display: inline-block; height: %s; width: 0;" height_str;
                        ]
                        ~children:[]
                  ]
            ]
      ]
