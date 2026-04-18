(* Test render module *)

open Typemail

let () =
  let simple_section = Section.v [
    Heading.to_element (Heading.h1 "Welcome to typemail");
    Paragraph.to_element (Paragraph.v "This is a test email.");
    Button.to_element (Button.v
      ~href:"https://example.com"
      ~background:(Color.solid "#4f46e5")
      ~text_color:Color.Brand.white
      ~width_px:200
      ~height_px:44
      "Get Started");
  ] in
  let email_elem = Section.to_element simple_section in

  match Render.render_email email_elem with
  | Ok email_html ->
      Printf.printf "✅ render_email test passed\n";
      Printf.printf "Email length: %d bytes\n" (String.length email_html);
      Printf.printf "Within Gmail limit: %b\n" (String.length email_html <= Render.gmail_limit_bytes)
  | Error msg ->
      Printf.printf "❌ render_email test failed: %s\n" msg
