(** Button component with Outlook-safe dimensions. *)

type t = {
  href: string;
  background: Color.t;
  text_color: Color.t;
  width_px: int;
  height_px: int;
  border_radius: int option;
  content: string;
}

let v ~href ~background ~text_color ~width_px ~height_px content =
  {href; background; text_color; width_px; height_px; border_radius = None; content}

let make ?(border_radius = None) ~href ~background ~text_color ~width_px ~height_px ~content () =
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
