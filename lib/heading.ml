(** Heading component with level for accessibility. *)

type level = H1 | H2 | H3 | H4 | H5 | H6

(** Content type - either plain text or rich inline formatting *)
type content =
  | Text of string
  | Inline of Inline.t list

type t = {
  level: level;
  color: Color.t option;
  font_size: Font_size.t option;
  text_align: Text_align.t option;
  content: content;
}

let level_to_tag = function
  | H1 -> "h1"
  | H2 -> "h2"
  | H3 -> "h3"
  | H4 -> "h4"
  | H5 -> "h5"
  | H6 -> "h6"

let tag heading = level_to_tag heading.level

let make ?color ?font_size ?text_align ~level ~content () =
  {level; color; font_size; text_align; content = Text content}

let of_children ?color ?font_size ?text_align ~level children =
  {level; color; font_size; text_align; content = Inline children}

let h1 ?color ?font_size ?text_align content =
  {level = H1; color; font_size; text_align; content = Text content}
let h2 ?color ?font_size ?text_align content =
  {level = H2; color; font_size; text_align; content = Text content}
let h3 ?color ?font_size ?text_align content =
  {level = H3; color; font_size; text_align; content = Text content}
let h4 ?color ?font_size ?text_align content =
  {level = H4; color; font_size; text_align; content = Text content}
let h5 ?color ?font_size ?text_align content =
  {level = H5; color; font_size; text_align; content = Text content}
let h6 ?color ?font_size ?text_align content =
  {level = H6; color; font_size; text_align; content = Text content}

let of_children_h1 ?color ?font_size ?text_align children =
  {level = H1; color; font_size; text_align; content = Inline children}
let of_children_h2 ?color ?font_size ?text_align children =
  {level = H2; color; font_size; text_align; content = Inline children}
let of_children_h3 ?color ?font_size ?text_align children =
  {level = H3; color; font_size; text_align; content = Inline children}
let of_children_h4 ?color ?font_size ?text_align children =
  {level = H4; color; font_size; text_align; content = Inline children}
let of_children_h5 ?color ?font_size ?text_align children =
  {level = H5; color; font_size; text_align; content = Inline children}
let of_children_h6 ?color ?font_size ?text_align children =
  {level = H6; color; font_size; text_align; content = Inline children}

let style_attributes h =
  let parts =
    List.filter_map (fun x -> x) [
      Option.map (fun c -> Printf.sprintf "color: %s;" (Color.to_css c)) h.color;
      Option.map (fun fs -> Printf.sprintf "font-size: %s;" (Font_size.to_css fs)) h.font_size;
      Option.map (fun ta -> Printf.sprintf "text-align: %s;" (Text_align.to_css ta)) h.text_align;
    ]
  in
  match parts with
  | [] -> []
  | parts -> ["style", String.concat " " parts]

let to_element heading =
  let tag = level_to_tag heading.level in
  (* Use inline style, not the HTML4 `color` attribute. The `color` attribute
     on <h1>..<h6> is ignored by every major email client; inline
     style="color: ..." is universally supported.
     See https://www.caniemail.com/features/css-background-color/ *)
  let attributes = style_attributes heading in
  let children = match heading.content with
    | Text s -> [Element.text s]
    | Inline inlines -> Inline.to_elements inlines
  in
  Element.Private.make @@
  Element.Private.builder ~tag ~attributes ~children
