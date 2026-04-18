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
  (* Use inline style, not the HTML4 `color` attribute. The `color` attribute
     on <p> is ignored by every major email client; inline style="color: ..."
     is universally supported.
     See https://www.caniemail.com/features/css-background-color/ *)
  let attributes =
    match paragraph.color with
    | None -> []
    | Some color -> ["style", Printf.sprintf "color: %s;" (Color.to_css color)]
  in
  let children = [Element.text paragraph.content] in
  Element.Private.make @@
    Element.Private.builder ~tag ~attributes ~children
