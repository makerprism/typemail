(** Button component with Outlook-safe dimensions. *)

(** Validate URL scheme - accepts http, https, and relative URLs *)
let is_valid_url url =
  let len = String.length url in
  if len = 0 then false
  else if String.starts_with ~prefix:"http://" url then true
  else if String.starts_with ~prefix:"https://" url then true
  else if String.starts_with ~prefix:"/" url then true
  else if String.starts_with ~prefix:"#" url then true  (* Anchor links *)
  else if String.starts_with ~prefix:"mailto:" url then true  (* Email links *)
  else
    (* Check for relative URLs without protocol *)
    not (String.contains url ':')

(** Estimate text width for button sizing.

    Uses conservative character width estimates for 16px sans-serif bold font
    (typical button styling). Accounts for:
    - Average character width: ~9px per char for sans-serif at 16px
    - Bold font weight: +15% width
    - Horizontal padding: ~32px (16px per side)

    This is a conservative estimate - actual width may vary by:
    - Font family differences across email clients
    - Character composition (W vs "i", etc.)
    - Language-specific character widths

    Returns width in pixels, rounded up to nearest multiple of 10 for cleaner values.
*)
let estimate_text_width ~text =
  let char_count = String.length text in
  (* Base width: ~9px per character for 16px sans-serif *)
  let base_width = char_count * 9 in
  (* Bold font adds ~15% width *)
  let bold_width = float_of_int base_width *. 1.15 in
  (* Add horizontal padding: 32px total (16px per side) *)
  let total_width = bold_width +. 32.0 in
  (* Round up to nearest 10 for cleaner values *)
  let rounded = Float.ceil (total_width /. 10.0) *. 10.0 in
  (* Ensure minimum width of 80px *)
  max 80 (int_of_float rounded)

type t = {
  href: string;
  background: Color.t;
  text_color: Color.t;
  width_px: int;
  height_px: int;
  border_radius: int option;
  content: string;
}

(** Auto-sized constructor - calculates width from text content *)
let v_auto ~href ~background ~text_color ~height_px content =
  if not (is_valid_url href) then
    invalid_arg "Button.v_auto: invalid URL scheme (only http, https, /, #, mailto allowed)";
  let width_px = estimate_text_width ~text:content in
  {href; background; text_color; width_px; height_px; border_radius = None; content}

(** Fixed-width constructor with overflow validation *)
let v ~href ~background ~text_color ~width_px ~height_px content =
  if not (is_valid_url href) then
    invalid_arg "Button.v: invalid URL scheme (only http, https, /, #, mailto allowed)";
  let estimated_width = estimate_text_width ~text:content in
  if estimated_width > width_px then
    Printf.ksprintf failwith
      "Button.v: text '%s' (estimated width: %dpx) exceeds specified width_px: %d. \
       Use Button.v_auto for automatic sizing or increase width_px to at least %d."
      content estimated_width width_px estimated_width;
  {href; background; text_color; width_px; height_px; border_radius = None; content}

let make ?(border_radius = None) ~href ~background ~text_color ~width_px ~height_px ~content () =
  if not (is_valid_url href) then
    invalid_arg "Button.make: invalid URL scheme (only http, https, /, #, mailto allowed)";
  let estimated_width = estimate_text_width ~text:content in
  if estimated_width > width_px then
    Printf.ksprintf failwith
      "Button.make: text '%s' (estimated width: %dpx) exceeds specified width_px: %d. \
       Use Button.v_auto for automatic sizing or increase width_px to at least %d."
      content estimated_width width_px estimated_width;
  {href; background; text_color; width_px; height_px; border_radius; content}

let to_element button =
  (* Convert Color.t to CSS strings for VML generator *)
  let bg_css = Color.to_css button.background in
  let text_css = Color.to_css button.text_color in

  (* Use VML generator to create bulletproof button.
     Returns structured Element.t with proper escaping throughout. *)
  Vml_generator.bulletproof_button
    ~width_px:button.width_px
    ~height_px:button.height_px
    ~background:bg_css
    ~text_color:text_css
    ~border_radius:button.border_radius
    ~content:button.content
    ~href:button.href
