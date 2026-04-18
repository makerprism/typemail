(** Core element type - opaque to prevent raw HTML injection.

    This type is abstract (private) in the implementation, which means
    there is NO way to construct an Element.t except through the
    provided smart constructors. This is typemail's core safety mechanism.

    There is NO raw_html constructor. If a pattern isn't expressible
    through the typed components, the correct fix is to add a new
    component, not to punch a hole in the type system.

    This design prevents:
    - XSS attacks via injected HTML
    - Breaking cross-client compatibility with unsupported CSS/HTML
    - Bypassing Outlook-specific constraints
*)

type t

(** Empty element *)
val empty : t

(** Create a text node *)
val text : string -> t

(** Create an element with tag, attributes, and children.

    This is INTERNAL ONLY and not exposed in the .mli interface.
    Component modules use this through their private access.
*)
module Private : sig
  type builder = private {
    tag: string;
    attributes: (string * string) list;
    children: t list;
  }

  val make : builder -> t

  (** Create a builder *)
  val builder :
    tag:string ->
    attributes:(string * string) list ->
    children:t list ->
    builder

  (** Merge attribute lists, later values override earlier ones *)
  val merge_attributes :
    (string * string) list ->
    (string * string) list ->
    (string * string) list
end

(** Render element to HTML string *)
val to_html : t -> string

(** Calculate total size in bytes for Gmail limit checking *)
val size_in_bytes : t -> int
