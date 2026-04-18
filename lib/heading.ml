(** Heading component with level for accessibility. *)

type level = H1 | H2 | H3 | H4 | H5 | H6

type t = {
  level: level;
  color: Color.t option;
  content: string;
}

let level_to_tag = function
  | H1 -> "h1"
  | H2 -> "h2"
  | H3 -> "h3"
  | H4 -> "h4"
  | H5 -> "h5"
  | H6 -> "h6"

let tag heading = level_to_tag heading.level

let make ?color ~level ~content () =
  {level; color; content}

let h1 ?color content = {level = H1; color; content}
let h2 ?color content = {level = H2; color; content}
let h3 ?color content = {level = H3; color; content}
let h4 ?color content = {level = H4; color; content}
let h5 ?color content = {level = H5; color; content}
let h6 ?color content = {level = H6; color; content}

let to_element heading =
  let tag = level_to_tag heading.level in
  (* Use inline style, not the HTML4 `color` attribute. The `color` attribute
     on <h1>..<h6> is ignored by every major email client; inline
     style="color: ..." is universally supported.
     See https://www.caniemail.com/features/css-background-color/ *)
  let attributes =
    match heading.color with
    | None -> []
    | Some color -> ["style", Printf.sprintf "color: %s;" (Color.to_css color)]
  in
  let children = [Element.text heading.content] in
  Element.Private.make @@
    Element.Private.builder ~tag ~attributes ~children
