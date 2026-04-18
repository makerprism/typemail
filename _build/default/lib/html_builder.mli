(** Safe HTML string construction.

    Internal module for building HTML strings. Prevents injection
    through careful escaping and attribute whitelist.

    This module is PRIVATE to the typemail_dll library and should
    not be exposed to end users.
*)

type t

(** Empty builder *)
val empty : t

(** Create a text node with escaped content *)
val text : string -> t

(** Create an HTML element with tag, attributes, and children.

    @param tag HTML tag name
    @param attributes List of (name, value) pairs
    @param children Child builders
*)
val tag :
  string ->
  attributes:(string * string) list ->
  children:t list ->
  t

(** Concatenate builders *)
val concat : t list -> t

(** Convert builder to HTML string *)
val to_string : t -> string

(** Escape HTML entities in text content

    Escapes: ampersand, less-than, greater-than, double-quote, single-quote
*)
val escape : string -> string
