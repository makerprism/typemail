(** Callout component: tinted block with optional left-border accent. *)

type t = {
  background: Color.t option;
  accent: Color.t option;
  padding: Spacing.t;
  children: Element.t list;
}

(* Default padding matches the typical inset used by Section examples
   and keeps Outlook-safe solid px values. *)
let default_padding = Spacing.Spacing.px16

(* Accent column is always 4px: this is the convention across
   transactional email design systems (React Email, MJML callouts,
   Postmark templates) and keeps cross-client rendering predictable. *)
let accent_width_px = 4

let make ?background ?accent ?(padding = default_padding) ~children () =
  (match background, accent with
   | None, None ->
       invalid_arg
         "Callout.make: at least one of ~background or ~accent must be \
          provided; a Callout with neither is just a Section"
   | _ -> ());
  {background; accent; padding; children}

let v ?accent ?(padding = default_padding) ~background children =
  {background = Some background; accent; padding; children}

let to_element callout =
  (* Table-level attributes: the background sits on the table so both the
     accent cell and the content cell share the tint. Outlook ignores CSS
     background on table cells reliably only when bgcolor is also set. *)
  let base_table_attributes = [
    "border", "0";
    "cellpadding", "0";
    "cellspacing", "0";
    "role", "presentation";
    "width", "100%";
  ] in
  let table_attributes = match callout.background with
    | None -> base_table_attributes
    | Some color ->
        ("bgcolor", Color.(color |> fallback |> to_css))
        :: ("style", "background-color: " ^ Color.to_style color ^ ";")
        :: base_table_attributes
  in

  let content_td =
    Element.Private.make @@ Element.Private.builder
      ~tag:"td"
      ~attributes:[
        "style", "padding: " ^ Spacing.to_css callout.padding ^ ";";
      ]
      ~children:callout.children
  in

  (* With an accent, render a two-column row: a fixed-width tinted cell on
     the left, then the content cell. Without an accent, a single content
     cell keeps the markup minimal. *)
  let row_children = match callout.accent with
    | None -> [content_td]
    | Some accent_color ->
        let accent_css = Color.to_style accent_color in
        let accent_fallback = Color.(accent_color |> fallback |> to_css) in
        let accent_td =
          Element.Private.make @@ Element.Private.builder
            ~tag:"td"
            ~attributes:[
              "width", string_of_int accent_width_px;
              "bgcolor", accent_fallback;
              "style",
              Printf.sprintf
                "width: %dpx; background-color: %s; font-size: 0; line-height: 0;"
                accent_width_px accent_css;
            ]
            (* Non-breaking space keeps the cell from collapsing in
               Outlook, where empty table cells are rendered 0-wide. *)
            ~children:[Element.text "\xC2\xA0"]
        in
        [accent_td; content_td]
  in

  Element.Private.make @@ Element.Private.builder
    ~tag:"table"
    ~attributes:table_attributes
    ~children:[Element.Private.make @@ Element.Private.builder
      ~tag:"tr"
      ~attributes:[]
      ~children:row_children
    ]
