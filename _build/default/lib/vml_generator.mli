(** VML fallback generation for Outlook.

    Outlook Desktop 2007-2024 uses Microsoft Word's rendering engine
    which doesn't support CSS shapes/gradients. We generate VML
    fallbacks that Outlook renders correctly.

    This module is PRIVATE to the typemail_dll library and should
    not be exposed to end users.

    caniemail reference:
    - https://www.caniemail.com/features/html-comments/
*)

(** Generate a bulletproof button with VML fallback for Outlook.

    Returns a structured Element.t tree with VML conditional comments.
    All user input (href, content) is properly escaped via Element.text.

    @param width_px Button width in pixels (required for Outlook)
    @param height_px Button height in pixels (required for Outlook)
    @param background Button background color (as CSS string)
    @param text_color Button text color (as CSS string)
    @param border_radius Optional border radius in pixels
    @param content Button text content
    @param href Button link URL
    @return Element.t with VML + fallback HTML structure
*)
val bulletproof_button :
  width_px:int ->
  height_px:int ->
  background:string ->
  text_color:string ->
  border_radius:int option ->
  content:string ->
  href:string ->
  Element.t
