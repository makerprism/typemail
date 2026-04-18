(** Section component with table-based layout for Outlook compatibility. *)

type t = {
  background: Color.t option;
  padding: Spacing.t option;
  padding_x: Spacing.t option;
  padding_y: Spacing.t option;
  children: Element.t list;
}

let make ?background ?padding ?padding_x ?padding_y ~children () =
  {background; padding; padding_x; padding_y; children}

let v children =
  {background = None; padding = None; padding_x = None; padding_y = None; children}

(* Axis-specific overrides (padding_x / padding_y) win over the uniform
   padding shorthand for the axis they cover. When only the uniform
   ~padding is set, emit the one-value CSS shorthand to preserve
   existing output. *)
let padding_style section =
  match section.padding_x, section.padding_y, section.padding with
  | None, None, None -> None
  | None, None, Some p ->
      Some ("padding: " ^ Spacing.to_css p ^ ";")
  | _, _, _ ->
      let y = match section.padding_y with
        | Some v -> v
        | None -> (match section.padding with Some v -> v | None -> Spacing.of_px_exn 0)
      in
      let x = match section.padding_x with
        | Some v -> v
        | None -> (match section.padding with Some v -> v | None -> Spacing.of_px_exn 0)
      in
      Some ("padding: " ^ Spacing.to_css y ^ " " ^ Spacing.to_css x ^ ";")

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
  let td_attributes = match padding_style section with
    | None -> []
    | Some style -> ["style", style]
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
