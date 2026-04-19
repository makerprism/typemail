(** Inline text formatting for rich text within Paragraph and Heading.

    This module provides inline formatting elements that can be composed
    to create rich text content with bold, italic, and links.

    All text content is HTML-escaped to prevent XSS. The API is designed
    to make unsafe patterns impossible: there is no way to inject raw HTML.

    caniemail references:
    - https://www.caniemail.com/features/html-a-href/
    - https://www.caniemail.com/features/html-strong/
    - https://www.caniemail.com/features/html-em/

    Example:
    {[
      let content = Inline.concat [
        Inline.text "Hello ";
        Inline.bold "world";
        Inline.text "! Visit ";
        Inline.link ~href:"https://example.com" "our site";
      ]
      let paragraph = Paragraph.of_inline content
    ]}
*)

type t =
  | Text of string
  | Bold of t
  | Italic of t
  | Link of {href: string; content: t}
  | Concat of t list

(** Plain text - HTML-escaped *)
let text (s : string) : t = Text s

(** Bold text using <strong> tag *)
let bold (content : string) : t = Bold (Text content)

(** Italic text using <em> tag *)
let italic (content : string) : t = Italic (Text content)

(** Hyperlink with href and link text *)
let link ~href (content : string) : t = Link {href; content = Text content}

(** Compose multiple inline elements into a single inline value.
    This is useful when you need mixed formatting in a single paragraph. *)
let rec concat (elements : t list) : t =
  match elements with
  | [] -> Text ""
  | [x] -> x
  | xs -> Concat xs

(** Flatten nested Concat nodes for more efficient rendering *)
let rec normalize : t -> t list = function
  | Text s -> [Text s]
  | Bold x -> [Bold x]
  | Italic x -> [Italic x]
  | Link l -> [Link l]
  | Concat xs ->
      List.concat (List.map normalize xs)

(** Convert inline content to Element.t children.
    Returns a list of Element.t values that can be used as children. *)
let rec to_elements : t -> Element.t list = function
  | Text s -> [Element.text s]
  | Bold x ->
      let children = to_elements x in
      [Element.Private.make @@ Element.Private.builder
         ~tag:"strong"
         ~attributes:[]
         ~children]
  | Italic x ->
      let children = to_elements x in
      [Element.Private.make @@ Element.Private.builder
         ~tag:"em"
         ~attributes:[]
         ~children]
  | Link {href; content} ->
      let children = to_elements content in
      [Element.Private.make @@ Element.Private.builder
         ~tag:"a"
         ~attributes:["href", href]
         ~children]
  | Concat xs ->
      List.concat (List.map to_elements xs)

(** Convert inline content to HTML string *)
let to_html (inline : t) : string =
  let elements = to_elements inline in
  elements |> List.map Element.to_html |> String.concat ""

(** Calculate size in bytes for Gmail limit checking *)
let rec size_in_bytes : t -> int = function
  | Text s ->
      (* Count UTF-8 bytes for text content *)
      let rec count_utf8_bytes str i acc =
        if i < 0 then acc
        else
          let char_byte_count =
            (* UTF-8: 0-127=1 byte, 194-223=2 bytes, 224-239=3 bytes, 240-244=4 bytes *)
            let c = Char.code str.[i] in
            if c < 0x80 then 1
            else if c < 0xE0 then 2
            else if c < 0xF0 then 3
            else 4 in
          count_utf8_bytes str (i - 1) (acc + char_byte_count) in
      count_utf8_bytes s (String.length s - 1) 0
  | Bold x ->
      (* <strong>...</strong> adds 17 characters *)
      17 + size_in_bytes x
  | Italic x ->
      (* <em>...</em> adds 9 characters *)
      9 + size_in_bytes x
  | Link {href; content} ->
      (* Link structure: <a href=URL>content</a>.
         For attribute escaping, & becomes &amp; (5 chars).
         In practice, most URLs don't need escaping, so we use length as approximation.
         This is a conservative estimate for limit checking. *)
      let attr_size = String.length href + 10 in
      9 + attr_size + size_in_bytes content (* <a> + </a> = 9 chars *)
  | Concat xs ->
      List.fold_left (fun acc x -> acc + size_in_bytes x) 0 xs
