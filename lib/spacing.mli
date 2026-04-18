(** Spacing and dimension values.

    All pixel dimensions are non-negative integers. Negative values
    are unrepresentable at the type level through validation in
    smart constructors.

    This prevents invalid CSS values like "width: -10px" which would
    cause rendering issues across email clients.
*)

type t

(** Construct a pixel value. Returns None if negative.

    @param px Non-negative pixel value
*)
val of_px : int -> t option

(** Construct a pixel value, raising exception if negative.

    @param px Non-negative pixel value
    @raise Invalid_argument if px < 0
*)
val of_px_exn : int -> t

(** Get the integer value *)
val to_int : t -> int

(** Convert to CSS string (e.g. "16px") *)
val to_css : t -> string

(** Common spacing values *)
module Spacing : sig
  val zero : t
  val px1 : t
  val px2 : t
  val px4 : t
  val px6 : t
  val px8 : t
  val px12 : t
  val px16 : t
  val px20 : t
  val px24 : t
  val px32 : t
  val px40 : t
  val px48 : t
  val px64 : t
end

(** Common dimension values *)
module Size : sig
  val auto : t
  val full : t
  (** 100% *)
end
