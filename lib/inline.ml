(** Inline text formatting for rich text content.

    This module provides inline formatting elements that can be composed
    to create rich text content with bold, italic, links, and code.

    All text content is HTML-escaped to prevent XSS. The API is designed
    to make unsafe patterns impossible: there is no way to inject raw HTML.

    Inline elements can be used in any context that accepts rich text:
    - Paragraph (body text)
    - Heading (titles)
    - List items (bullet points)
    - Table cells (data display)

    caniemail references:
    - https://www.caniemail.com/features/html-a-href/ (links: 100% supported)
    - https://www.caniemail.com/features/html-strong/ (bold: 100% supported)
    - https://www.caniemail.com/features/html-em/ (italic: 100% supported)
    - https://www.caniemail.com/features/html-code/ (code: 98% supported)

    Example:
    {[
      (* Compose inline content naturally *)
      let content = [
        Inline.v "Hello ";
        Inline.bold (Inline.v "world");
        Inline.v "! Visit ";
        Inline.link ~href:"https://example.com" (Inline.v "our site");
      ]

      (* Use in any context *)
      let paragraph = Paragraph.of_children content
    ]}
*)

type t =
  | Text of string
  | Bold of t
  | Italic of t
  | Link of {href: string; content: t}
  | Code of string
  | Span of {color: Color.t option; content: string}

(** Plain text - HTML-escaped *)
let v (s : string) : t = Text s

(** Bold text using <strong> tag *)
let bold (content : t) : t = Bold content

(** Italic text using <em> tag *)
let italic (content : t) : t = Italic content

(** Hyperlink with href and content *)
let link ~href (content : t) : t = Link {href; content}

(** Code span with monospace font and gray background *)
let code (content : string) : t = Code content

(** Colored span with optional color *)
let span ?color (content : string) : t = Span {color; content}

(** Convert a single inline element to Element.t list *)
let rec to_element_list : t -> Element.t list = function
  | Text s -> [Element.text s]
  | Bold x ->
      let children = to_element_list x in
      [Element.Private.make @@ Element.Private.builder
         ~tag:"strong"
         ~attributes:[]
         ~children]
  | Italic x ->
      let children = to_element_list x in
      [Element.Private.make @@ Element.Private.builder
         ~tag:"em"
         ~attributes:[]
         ~children]
  | Link {href; content} ->
      let children = to_element_list content in
      [Element.Private.make @@ Element.Private.builder
         ~tag:"a"
         ~attributes:["href", href]
         ~children]
  | Code s ->
      let children = [Element.text s] in
      let style = "background-color: #f3f4f6; padding: 2px 6px; border-radius: 3px; font-family: monospace; font-size: 0.9em;" in
      [Element.Private.make @@ Element.Private.builder
         ~tag:"code"
         ~attributes:["style", style]
         ~children]
  | Span {color; content} ->
      let children = [Element.text content] in
      let attributes = match color with
        | None -> []
        | Some c -> ["style", Printf.sprintf "color: %s;" (Color.to_css c)]
      in
      [Element.Private.make @@ Element.Private.builder
         ~tag:"span"
         ~attributes
         ~children]

(** Convert inline list to Element.t list for rendering *)
let to_elements (elements : t list) : Element.t list =
  List.concat (List.map to_element_list elements)

(** Convert inline content to HTML string *)
let to_html (inlines : t list) : string =
  let elements = to_elements inlines in
  elements |> List.map Element.to_html |> String.concat ""

(** Helper: count UTF-8 bytes in a string *)
let count_utf8_bytes (str : string) : int =
  let rec loop i acc =
    if i < 0 then acc
    else
      let char_byte_count =
        (* UTF-8: 0-127=1 byte, 194-223=2 bytes, 224-239=3 bytes, 240-244=4 bytes *)
        let c = Char.code str.[i] in
        if c < 0x80 then 1
        else if c < 0xE0 then 2
        else if c < 0xF0 then 3
        else 4 in
      loop (i - 1) (acc + char_byte_count) in
  loop (String.length str - 1) 0

(** Calculate size in bytes for Gmail limit checking *)
let rec size_in_bytes_single : t -> int = function
  | Text s -> count_utf8_bytes s
  | Bold x ->
      (* <strong>...</strong> adds 17 characters *)
      17 + size_in_bytes_single x
  | Italic x ->
      (* <em>...</em> adds 9 characters *)
      9 + size_in_bytes_single x
  | Link {href; content} ->
      (* Link structure: <a href=URL>content</a>.
         For attribute escaping, & becomes &amp; (5 chars).
         In practice, most URLs don't need escaping, so we use length as approximation.
         This is a conservative estimate for limit checking. *)
      let attr_size = String.length href + 10 in
      9 + attr_size + size_in_bytes_single content (* <a> + </a> = 9 chars *)
  | Code s ->
      (* <code style="...">content</code> *)
      let content_size = count_utf8_bytes s in
      let style_size = String.length "background-color: #f3f4f6; padding: 2px 6px; border-radius: 3px; font-family: monospace; font-size: 0.9em;" in
      13 + style_size + 7 + content_size (* <code style="">content</code> *)
  | Span {color; content} ->
      let content_size = count_utf8_bytes content in
      match color with
      | None -> 6 + content_size (* <span>content</span> *)
      | Some c ->
          let color_css = Color.to_css c in
          let style_size = String.length color_css + 7 in (* "color: " + color + ";" *)
          13 + style_size + 7 + content_size (* <span style="">content</span> *)

let size_in_bytes (inlines : t list) : int =
  List.fold_left (fun acc x -> acc + size_in_bytes_single x) 0 inlines
