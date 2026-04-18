(** Paragraph component for body text. *)

type t = {
  content: string;
  color: Color.t option;
  font_size: Font_size.t option;
  font_style: Font_style.t option;
  text_align: Text_align.t option;
}

let make ?color ?font_size ?font_style ?text_align ~content () =
  {content; color; font_size; font_style; text_align}

let v content =
  {content; color = None; font_size = None; font_style = None; text_align = None}

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
  let children = [Element.text paragraph.content] in
  Element.Private.make @@
  Element.Private.builder ~tag ~attributes ~children
