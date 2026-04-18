(** Font size values in pixels.

    Font sizes are clamped to the 8..72px range. Values outside this
    range are not expressible: [of_px] returns [None], and [of_px_exn]
    raises [Invalid_argument]. Email clients render text below 8px
    unreliably and above 72px is almost never appropriate for body or
    heading content in a transactional email.

    caniemail reference:
    - https://www.caniemail.com/features/css-font-size/
*)

type t

(** Construct a font size from pixels. Returns [None] if the value is
    outside the supported 8..72 range.

    @param px Pixel value in 8..72
*)
val of_px : int -> t option

(** Construct a font size from pixels, raising on invalid input.

    @param px Pixel value in 8..72
    @raise Invalid_argument if [px] is outside 8..72
*)
val of_px_exn : int -> t

(** Convert to CSS value (e.g. "13px") *)
val to_css : t -> string

(** 13px - small muted text (footers, fine print) *)
val small : t

(** 16px - default body text size *)
val default : t

(** 20px - emphasized body text *)
val large : t

(** 24px - hero headings *)
val xlarge : t
