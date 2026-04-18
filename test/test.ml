(* Basic tests to verify compilation *)

(* Open the Typemail module to access its submodules *)
open Typemail

let () =
  (* Test Color *)
  let red = Color.solid "#ff0000" in
  let gradient = Color.gradient
    ~direction:"to right"
    ~colors:["#667eea"; "#764ba2"]
    ~fallback:red in
  let _ = Color.to_css gradient in

  (* Test Spacing *)
  let spacing = Spacing.of_px_exn 16 in
  let _ = Spacing.to_css spacing in

  (* Test Element *)
  let elem = Element.text "Hello, world!" in
  let html = Element.to_html elem in
  Printf.printf "Element test passed. HTML: %s\n" html;

  (* Test Heading *)
  let h1 = Heading.h1 "Welcome to typemail!" in
  let h1_elem = Heading.to_element h1 in
  let h1_html = Element.to_html h1_elem in
  Printf.printf "H1 test passed. HTML: %s\n" h1_html;

  let h2_colored = Heading.h2 ~color:Color.Brand.indigo_600 "You're invited" in
  let h2_elem = Heading.to_element h2_colored in
  let h2_html = Element.to_html h2_elem in
  Printf.printf "H2 test passed. HTML: %s\n" h2_html;

  (* Test Paragraph *)
  let p1 = Paragraph.v "This is a paragraph of text." in
  let p1_elem = Paragraph.to_element p1 in
  let p1_html = Element.to_html p1_elem in
  Printf.printf "Paragraph test passed. HTML: %s\n" p1_html;

  let p2_colored = Paragraph.make ~color:Color.Brand.gray_500 ~content:"This is gray text." () in
  let p2_elem = Paragraph.to_element p2_colored in
  let p2_html = Element.to_html p2_elem in
  Printf.printf "Colored paragraph test passed. HTML: %s\n" p2_html;

  (* Test Button *)
  let button = Button.v
    ~href:"https://example.com"
    ~background:(Color.solid "#4f46e5")
    ~text_color:Color.Brand.white
    ~width_px:200
    ~height_px:44
    "Click me" in
  let button_elem = Button.to_element button in
  let button_html = Element.to_html button_elem in
  Printf.printf "Button test passed. HTML: %s\n" button_html;

  Printf.printf "\n✅ All tests passed!\n"
