(** Safe HTML string construction. *)

type t =
  | Empty
  | Text of string
  | Element of {
      tag: string;
      attributes: (string * string) list;
      children: t list;
    }
  | Concat of t list

let empty = Empty

let escape str =
  (* Simple HTML entity escaping *)
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

let text content = Text (escape content)

let tag tag ~attributes ~children =
  Element {tag; attributes; children}

let concat = function
  | [] -> Empty
  | [single] -> single
  | multiple -> Concat multiple

let rec to_string = function
  | Empty -> ""
  | Text content -> content
  | Element {tag; attributes; children} ->
      let attrs = attributes
                  |> List.map (fun (k, v) ->
                      Printf.sprintf "%s=\"%s\"" k (escape v))
                  |> String.concat " " in
      let children_str = children
                         |> List.map to_string
                         |> String.concat "" in
      if attrs = "" then
        Printf.sprintf "<%s>%s</%s>" tag children_str tag
      else
        Printf.sprintf "<%s %s>%s</%s>" tag attrs children_str tag
  | Concat builders ->
      builders
      |> List.map to_string
      |> String.concat ""
