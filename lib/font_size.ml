(** Font size values in pixels. *)

type t = int

let min_px = 8
let max_px = 72

let of_px px =
  if px < min_px || px > max_px then None
  else Some px

let of_px_exn px =
  if px < min_px || px > max_px then
    invalid_arg "Font_size.of_px_exn: pixel value outside 8..72"
  else px

let to_css t = Printf.sprintf "%dpx" t

let small = 13
let default = 16
let large = 20
let xlarge = 24
