(** Heading component with level for accessibility.

    Headings are distinct from Paragraph components so screen readers
    can properly distinguish document structure. The level is enforced
    at compile time - you cannot silently downgrade a Heading to a Text
    node (unlike MJML).

    caniemail reference:
    - https://www.caniemail.com/features/html-h1-h6/

    Example:
    {[
      Heading.h1 ~color:Color.Brand.white "You're invited"
      Heading.h2 "Welcome!"
    ]}
*)

type level = H1 | H2 | H3 | H4 | H5 | H6

type t = private {
  level: level;
  color: Color.t option;
  content: string;
}

(** Smart constructors for each heading level.

    @param color Optional text color
    @param content Heading text content (will be HTML-escaped)
*)
val h1 : ?color:Color.t -> string -> t
val h2 : ?color:Color.t -> string -> t
val h3 : ?color:Color.t -> string -> t
val h4 : ?color:Color.t -> string -> t
val h5 : ?color:Color.t -> string -> t
val h6 : ?color:Color.t -> string -> t

(** General constructor with explicit level *)
val make : ?color:Color.t -> level:level -> content:string -> unit -> t

(** Convert to Element.t for rendering *)
val to_element : t -> Element.t

(** Get heading tag as string ("h1", "h2", etc.) *)
val tag : t -> string
