(** Text alignment. *)

type t =
  | Left
  | Center
  | Right

let to_css = function
  | Left -> "left"
  | Center -> "center"
  | Right -> "right"
