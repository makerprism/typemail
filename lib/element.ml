(** Core element type - opaque to prevent raw HTML injection. *)

type t =
  | Empty
  | Text of string
  | Element of {
      tag: string;
      attributes: (string * string) list;
      children: t list;
    }
  | Comment of string  (** HTML comment - for VML conditional comments *)

let empty = Empty

let text content = Text content

module Private = struct
  type builder = {
    tag: string;
    attributes: (string * string) list;
    children: t list;
  }

  let make {tag; attributes; children} =
    Element {tag; attributes; children}

  let builder ~tag ~attributes ~children =
    {tag; attributes; children}

  let comment content = Comment content

  let merge_attributes attrs1 attrs2 =
    (* Merge two attribute lists, with attrs2 taking precedence *)
    let rec merge acc = function
      | [] -> List.rev acc
      | (key, value) :: rest ->
          let new_acc =
            if List.exists (fun (k, _) -> k = key) acc then
              acc (* Keep first occurrence *)
            else
              (key, value) :: acc in
          merge new_acc rest in
    merge (List.rev attrs2) attrs1
end

let escape_html str =
  (* Escape HTML entities - used for both text content and attribute values *)
  let len = String.length str in
  let result = Buffer.create (len * 2) in
  for i = 0 to len - 1 do
    match str.[i] with
    | '&' -> Buffer.add_string result "&amp;"
    | '<' -> Buffer.add_string result "&lt;"
    | '>' -> Buffer.add_string result "&gt;"
    | '"' -> Buffer.add_string result "&quot;"
    | '\'' -> Buffer.add_string result "&#39;"
    | c -> Buffer.add_char result c
  done;
  Buffer.contents result

let rec to_html = function
  | Empty -> ""
  | Text content ->
      (* Escape HTML entities in text content *)
      escape_html content
  | Comment content ->
      (* HTML comment - for VML conditional comments.
         Content is NOT escaped because it's part of the HTML structure.
         Only used internally by VML generator with controlled input. *)
      Printf.sprintf "<!--%s-->" content
  | Element {tag; attributes; children} ->
      let attrs = attributes
                  |> List.map (fun (k, v) ->
                      Printf.sprintf "%s=\"%s\"" k (escape_html v))
                  |> String.concat " " in
      let children_html = List.map to_html children |> String.concat "" in
      if attrs = "" then
        Printf.sprintf "<%s>%s</%s>" tag children_html tag
      else
        Printf.sprintf "<%s %s>%s</%s>" tag attrs children_html tag

let rec size_in_bytes = function
  | Empty -> 0
  | Text content ->
      (* Count UTF-8 bytes, not characters. For ASCII this is the same,
         but for non-ASCII we need to count multi-byte sequences *)
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
      count_utf8_bytes content (String.length content - 1) 0
  | Comment content ->
      (* HTML comments: <!--content--> *)
      String.length content + 7
  | Element {tag; attributes; children} ->
      let attr_size = List.fold_left (fun acc (k, v) ->
        acc + String.length k + String.length v + 4) 0 attributes in
      let children_size = List.fold_left (fun acc child ->
        acc + size_in_bytes child) 0 children in
      String.length tag * 2 + 5 + attr_size + children_size
