(** Font style (upright vs italic).

    Restricted to the two values supported reliably across all email
    clients. Oblique is intentionally omitted because it is rendered
    inconsistently and is rarely needed in transactional email.

    caniemail reference:
    - https://www.caniemail.com/features/css-font-style/
*)

type t =
  | Normal
  | Italic

(** Convert to CSS value ("normal" | "italic") *)
val to_css : t -> string
