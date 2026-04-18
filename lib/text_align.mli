(** Text alignment.

    Justified alignment is intentionally omitted: it produces uneven
    whitespace across email clients that lack hyphenation support and
    is discouraged for transactional email.

    caniemail reference:
    - https://www.caniemail.com/features/css-text-align/
*)

type t =
  | Left
  | Center
  | Right

(** Convert to CSS value ("left" | "center" | "right") *)
val to_css : t -> string
