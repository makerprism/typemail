(** Font style (upright vs italic). *)

type t =
  | Normal
  | Italic

let to_css = function
  | Normal -> "normal"
  | Italic -> "italic"
