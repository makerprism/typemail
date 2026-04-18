(** Image component with accessibility-first design. *)

type t = {
  src: string;
  alt: string;
  width_px: int option;
  height_px: int option;
  border_radius: int option;
}

(** Basic validation for URL scheme - accepts http, https, and relative URLs *)
let is_valid_url url =
  let len = String.length url in
  if len = 0 then false
  else if String.starts_with ~prefix:"http://" url then true
  else if String.starts_with ~prefix:"https://" url then true
  else if String.starts_with ~prefix:"/" url then true
  else if String.starts_with ~prefix:"./" url then true
  else
    (* Check for relative URLs without protocol *)
    not (String.contains url ':')

(** Variant constructor for common case - no border radius *)
let v ~src ~alt ~width_px ~height_px =
  if not (is_valid_url src) then
    invalid_arg "Image.v: invalid URL scheme";
  if alt = "" then
    invalid_arg "Image.v: alt text cannot be empty (accessibility requirement)";
  {src; alt; width_px = Some width_px; height_px = Some height_px; border_radius = None}

(** Full constructor with optional dimensions and border radius *)
let make ?width_px ?height_px ?border_radius ~src ~alt () =
  if not (is_valid_url src) then
    invalid_arg "Image.make: invalid URL scheme";
  if alt = "" then
    invalid_arg "Image.make: alt text cannot be empty (accessibility requirement)";
  {src; alt; width_px; height_px; border_radius}

(** Convert to Element.t for rendering *)
let to_element img =
  (* Base attributes - src and required alt *)
  let attributes = [
    "src", img.src;
    "alt", img.alt;  (* Will be escaped by Element module *)
  ] in
  (* Add width if specified *)
  let attributes = match img.width_px with
    | None -> attributes
    | Some w -> ("width", string_of_int w) :: attributes
  in
  (* Add height if specified *)
  let attributes = match img.height_px with
    | None -> attributes
    | Some h -> ("height", string_of_int h) :: attributes
  in
  (* Add border radius style if specified *)
  let attributes = match img.border_radius with
    | None -> attributes
    | Some r -> ("style", "border-radius: " ^ string_of_int r ^ "px;") :: attributes
  in
  Element.Private.make @@ Element.Private.builder
    ~tag:"img"
    ~attributes
    ~children:[]
