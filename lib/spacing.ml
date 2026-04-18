(** Spacing and dimension values. *)

type t = int

let of_px px =
  if px < 0 then None
  else Some px

let of_px_exn px =
  if px < 0 then
    invalid_arg "Spacing.of_px_exn: negative pixel value"
  else px

let to_int t = t

let to_css t = Printf.sprintf "%dpx" t

(** Common spacing values *)
module Spacing = struct
  let zero = 0
  let px1 = 1
  let px2 = 2
  let px4 = 4
  let px6 = 6
  let px8 = 8
  let px12 = 12
  let px16 = 16
  let px20 = 20
  let px24 = 24
  let px32 = 32
  let px40 = 40
  let px48 = 48
  let px64 = 64
end

module Size = struct
  let auto = 0
  let full = 100
end
