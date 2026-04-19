(** Button component with Outlook-safe dimensions and security.

    Buttons require explicit height because Outlook Desktop 2007-2024
    ignores CSS sizing and requires inline dimensions on VML elements.
    Width can be automatically calculated from text content or explicitly
    specified with overflow validation.

    URLs are validated for security - only http, https, relative paths (/),
    anchor links (#), and mailto links are allowed. Dangerous schemes like
    javascript:, data:, and vbscript: are rejected at construction time.

    caniemail references:
    - https://www.caniemail.com/features/css-padding/
    - https://www.caniemail.com/features/css-linear-gradient/
    - https://www.caniemail.com/features/html-comments/

    Examples:
    {[
      (* Auto-sized button - width calculated from text *)
      Button.v_auto
        ~href:"https://example.com"
        ~background:(Color.solid "#4f46e5")
        ~text_color:Color.Brand.white
        ~height_px:44
        "Click me"

      (* Fixed-width button - validates text fits *)
      Button.v
        ~href:"https://example.com"
        ~background:(Color.solid "#4f46e5")
        ~text_color:Color.Brand.white
        ~width_px:200
        ~height_px:44
        "Click me"
    ]}
*)

type t = private {
  href: string;
  background: Color.t;
  text_color: Color.t;
  width_px: int;
  height_px: int;
  border_radius: int option;
  content: string;
}

(** Auto-sized constructor - calculates width from text content.

    Uses conservative character width estimates for 16px sans-serif bold font.
    Returns a button with width automatically sized to fit the text plus padding.
    Use this for buttons with varying text lengths to prevent overflow bugs.

    @param href Button link URL (validated for security)
    @param background Button background color
    @param text_color Button text color
    @param height_px Button height in pixels (required for Outlook VML)
    @param content Button text content (width calculated from this)
    @return Button with auto-calculated width
    @raise Invalid_argument if URL scheme is invalid
*)
val v_auto :
  href:string ->
  background:Color.t ->
  text_color:Color.t ->
  height_px:int ->
  string ->
  t

(** Fixed-width constructor with overflow validation.

    Validates that the text content fits within the specified width.
    Raises an exception if the estimated text width exceeds width_px.

    @param href Button link URL (validated for security)
    @param background Button background color
    @param text_color Button text color
    @param width_px Button width in pixels (required for Outlook VML)
    @param height_px Button height in pixels (required for Outlook VML)
    @param content Button text content
    @return Button with fixed width
    @raise Invalid_argument if URL scheme is invalid
    @raise Failure if text is too long for specified width
*)
val v :
  href:string ->
  background:Color.t ->
  text_color:Color.t ->
  width_px:int ->
  height_px:int ->
  string ->
  t

(** Full constructor with optional border radius and overflow validation.

    Validates that the text content fits within the specified width.
    Raises an exception if the estimated text width exceeds width_px.

    @param border_radius Optional border radius in pixels
    @param href Button link URL (validated for security)
    @param background Button background color
    @param text_color Button text color
    @param width_px Button width in pixels (required for Outlook VML)
    @param height_px Button height in pixels (required for Outlook VML)
    @param content Button text content
    @return Button with fixed width and optional border radius
    @raise Invalid_argument if URL scheme is invalid
    @raise Failure if text is too long for specified width
*)
val make :
  ?border_radius:int option ->
  href:string ->
  background:Color.t ->
  text_color:Color.t ->
  width_px:int ->
  height_px:int ->
  content:string ->
  unit ->
  t

(** Convert to Element.t for rendering *)
val to_element : t -> Element.t
