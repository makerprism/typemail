(** Paragraph component for body text. *)

type t = {
  content: string;
  color: Color.t option;
}

let make ?color ~content () =
  {content; color}

let v content = {content; color = None}

let to_element paragraph =
  let tag = "p" in
  let attributes =
    match paragraph.color with
    | None -> []
    | Some color -> ["color", Color.to_css color]
  in
  let children = [Element.text paragraph.content] in
  Element.Private.make @@
    Element.Private.builder ~tag ~attributes ~children
