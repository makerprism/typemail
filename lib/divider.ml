(** Horizontal divider/separator line. *)

type t = {
  color: Color.t option;
  height: Spacing.t;
}

let v ?color ?height () =
  let height = Option.value ~default:Spacing.Spacing.px1 height in
  {color; height}

let make ?color ~height () =
  {color; height}

let to_element divider =
  (* Build inline styles *)
  let border_color = match divider.color with
    | None -> "border-color: #cccccc;"
    | Some c -> Printf.sprintf "border-color: %s;" (Color.to_css c)
  in
  let height_style = Printf.sprintf "height: %s;" (Spacing.to_css divider.height) in
  let styles = [
    "border: 0;";
    "border-top: 1px solid;";
    border_color;
    height_style;
    "margin: 0;";
    "width: 100%;";
  ] |> String.concat "" in

  Element.Private.make @@
    Element.Private.builder
      ~tag:"hr"
      ~attributes:["style", styles]
      ~children:[]
