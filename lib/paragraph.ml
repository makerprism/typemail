(** Paragraph component for body text. *)

type content =
  | Text of string
  | Rich of Inline.t list

type t = {
  content: content;
  color: Color.t option;
  font_size: Font_size.t option;
  font_style: Font_style.t option;
  text_align: Text_align.t option;
}

let make ?color ?font_size ?font_style ?text_align ?content ?children () =
  match children, content with
  | Some inlines, _ -> {content = Rich inlines; color; font_size; font_style; text_align}
  | None, Some s -> {content = Text s; color; font_size; font_style; text_align}
  | None, None ->
      invalid_arg "Paragraph.make: at least one of ~content or ~children is required"

let v content =
  {content = Text content; color = None; font_size = None; font_style = None; text_align = None}

let of_children ?color ?font_size ?font_style ?text_align children =
  {content = Rich children; color; font_size; font_style; text_align}

let style_attributes p =
  let parts =
    List.filter_map (fun x -> x) [
      Option.map (fun c -> Printf.sprintf "color: %s;" (Color.to_css c)) p.color;
      Option.map (fun fs -> Printf.sprintf "font-size: %s;" (Font_size.to_css fs)) p.font_size;
      Option.map (fun fs -> Printf.sprintf "font-style: %s;" (Font_style.to_css fs)) p.font_style;
      Option.map (fun ta -> Printf.sprintf "text-align: %s;" (Text_align.to_css ta)) p.text_align;
    ]
  in
  match parts with
  | [] -> []
  | parts -> ["style", String.concat " " parts]

let to_element paragraph =
  let tag = "p" in
  (* Use inline style, not the HTML4 `color` attribute. The `color` attribute
     on <p> is ignored by every major email client; inline style="color: ..."
     is universally supported.
     See https://www.caniemail.com/features/css-background-color/ *)
  let attributes = style_attributes paragraph in
  let children = match paragraph.content with
    | Text s -> [Element.text s]
    | Rich inlines -> List.map Inline.to_element inlines
  in
  Element.Private.make @@
  Element.Private.builder ~tag ~attributes ~children
