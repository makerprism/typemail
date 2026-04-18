(** Section component with table-based layout for Outlook compatibility. *)

type t = {
  background: Color.t option;
  padding: Spacing.t option;
  children: Element.t list;
}

let make ?background ?padding ~children () =
  {background; padding; children}

let v children = {background = None; padding = None; children}

let to_element section =
  (* Create table wrapper with presentation role *)
  let table_attributes = [
    "border", "0";
    "cellpadding", "0";
    "cellspacing", "0";
    "role", "presentation";
    "width", "100%";
  ] in

  (* Add background color if provided - use bgcolor for Outlook compatibility *)
  let table_attributes = match section.background with
    | None -> table_attributes
    | Some color ->
        (* Use fallback color for bgcolor attribute - Outlook requires solid colors *)
        ("bgcolor", Color.(color |> fallback |> to_css)) :: table_attributes
  in

  (* For gradients, also add inline CSS for modern clients *)
  let table_attributes = match section.background with
    | None -> table_attributes
    | Some color ->
        (* Add background style for gradients in modern clients *)
        let style = Color.to_style color in
        (* Merge with existing attributes, style takes precedence *)
        if List.exists (fun (k, _) -> k = "style") table_attributes then
          (* Shouldn't happen since we don't set style above, but handle gracefully *)
          table_attributes
        else
          ("style", style) :: table_attributes
  in

  (* Create table cell with padding *)
  let td_attributes = match section.padding with
    | None -> []
    | Some padding -> ["style", "padding: " ^ Spacing.to_css padding ^ ";"]
  in

  (* Create properly nested structure: table > tr > td > children *)
  Element.Private.make @@
    Element.Private.builder
      ~tag:"table"
      ~attributes:table_attributes
      ~children:[Element.Private.make @@
        Element.Private.builder
          ~tag:"tr"
          ~attributes:[]
          ~children:[Element.Private.make @@
            Element.Private.builder
              ~tag:"td"
              ~attributes:td_attributes
              ~children:section.children
          ]
      ]
