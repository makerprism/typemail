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

  (* Test Column *)
  let col1 = Column.v
    ~width:200
    ~vertical_align:"top"
    [Heading.to_element (Heading.h2 "Column 1"); Paragraph.to_element (Paragraph.v "Content in column 1")] in
  let col1_elem = Column.to_element col1 in
  let col1_html = Element.to_html col1_elem in
  Printf.printf "Column 1 test passed. HTML: %s\n" col1_html;

  let col2 = Column.make
    ~width:300
    ~vertical_align:"middle"
    ~children:[Heading.to_element (Heading.h3 "Column 2"); Paragraph.to_element (Paragraph.v "Content in column 2")]
    () in
  let col2_elem = Column.to_element col2 in
  let col2_html = Element.to_html col2_elem in
  Printf.printf "Column 2 test passed. HTML: %s\n" col2_html;

  let col3 = Column.v
    [Heading.to_element (Heading.h2 "Column 3"); Paragraph.to_element (Paragraph.v "Auto-width column")] in
  let col3_elem = Column.to_element col3 in
  let col3_html = Element.to_html col3_elem in
  Printf.printf "Column 3 test passed. HTML: %s\n" col3_html;

  (* Test Divider *)
  let divider1 = Divider.v () in
  let divider1_elem = Divider.to_element divider1 in
  let divider1_html = Element.to_html divider1_elem in
  Printf.printf "Divider (default) test passed. HTML: %s\n" divider1_html;

  let divider2 = Divider.v ~color:(Color.solid "#e5e7eb") ~height:(Spacing.of_px_exn 2) () in
  let divider2_elem = Divider.to_element divider2 in
  let divider2_html = Element.to_html divider2_elem in
  Printf.printf "Divider (custom) test passed. HTML: %s\n" divider2_html;

  (* Test Spacer *)
  let spacer1 = Spacer.v () in
  let spacer1_elem = Spacer.to_element spacer1 in
  let spacer1_html = Element.to_html spacer1_elem in
  Printf.printf "Spacer (default) test passed. HTML: %s\n" spacer1_html;

  let spacer2 = Spacer.v ~height:(Spacing.of_px_exn 32) () in
  let spacer2_elem = Spacer.to_element spacer2 in
  let spacer2_html = Element.to_html spacer2_elem in
  Printf.printf "Spacer (custom) test passed. HTML: %s\n" spacer2_html;

  (* Test Footer *)
  let footer1 = Footer.v "© 2024 Company Name" in
  let footer1_elem = Footer.to_element footer1 in
  let footer1_html = Element.to_html footer1_elem in
  Printf.printf "Footer (no background) test passed. HTML: %s\n" footer1_html;

  let footer2 = Footer.v ~background:(Color.solid "#1f2937") "© 2024 Company Name. All rights reserved." in
  let footer2_elem = Footer.to_element footer2 in
  let footer2_html = Element.to_html footer2_elem in
  Printf.printf "Footer (with background) test passed. HTML: %s\n" footer2_html;

  (* Test Section *)
  let section1 = Section.v
    [Heading.to_element (Heading.h1 "Section Title"); Paragraph.to_element (Paragraph.v "Section content")] in
  let section1_elem = Section.to_element section1 in
  let section1_html = Element.to_html section1_elem in
  Printf.printf "Section test passed. HTML: %s\n" section1_html;

  let section2_styled = Section.make
    ~background:(Color.solid "#f3f4f6")
    ~padding:(Spacing.of_px_exn 16)
    ~children:[Heading.to_element (Heading.h2 "Styled Section"); Paragraph.to_element (Paragraph.v "With padding and background")]
    () in
  let section2_elem = Section.to_element section2_styled in
  let section2_html = Element.to_html section2_elem in
  Printf.printf "Styled section test passed. HTML: %s\n" section2_html;

  let section3_gradient = Section.make
    ~background:(Color.gradient
      ~direction:"to bottom"
      ~colors:["#667eea"; "#764ba2"]
      ~fallback:(Color.solid "#667eea"))
    ~padding:(Spacing.of_px_exn 24)
    ~children:[Heading.to_element (Heading.h3 "Gradient Section"); Paragraph.to_element (Paragraph.v "Modern clients see gradient")]
    () in
  let section3_elem = Section.to_element section3_gradient in
  let section3_html = Element.to_html section3_elem in
  Printf.printf "Gradient section test passed. HTML: %s\n" section3_html;

  (* Test Image *)
  let img1 = Image.v
    ~src:"https://example.com/logo.png"
    ~alt:"Company Logo"
    ~width_px:200
    ~height_px:50 in
  let img1_elem = Image.to_element img1 in
  let img1_html = Element.to_html img1_elem in
  Printf.printf "Image 1 test passed. HTML: %s\n" img1_html;

  let img2 = Image.make
    ~src:"https://example.com/photo.jpg"
    ~alt:"Team photo"
    ~width_px:400
    ~height_px:300
    ~border_radius:8
    () in
  let img2_elem = Image.to_element img2 in
  let img2_html = Element.to_html img2_elem in
  Printf.printf "Image 2 test passed. HTML: %s\n" img2_html;

  let img3 = Image.make
    ~src:"/assets/icon.svg"
    ~alt:"Settings icon"
    () in
  let img3_elem = Image.to_element img3 in
  let img3_html = Element.to_html img3_elem in
  Printf.printf "Image 3 test passed. HTML: %s\n" img3_html;

  (* Test Render module *)
  let simple_email_section = Section.v [
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
  let simple_email = Section.to_element simple_email_section in
  match Render.render_html simple_email with
  | Ok html -> Printf.printf "render_html test passed. Length: %d bytes\n" (String.length html)
  | Error msg -> Printf.printf "render_html test failed: %s\n" msg;

  match Render.render_email simple_email with
  | Ok email_html -> Printf.printf "render_email test passed. Length: %d bytes\n" (String.length email_html)
  | Error msg -> Printf.printf "render_email test failed: %s\n" msg;

  (* Test Gmail limit checking *)
  let small_email_section = Section.v [Heading.to_element (Heading.h2 "Small")] in
  let small_email = Section.to_element small_email_section in
  Printf.printf "Small email within Gmail limit: %b\n" (Render.within_gmail_limit (Element.to_html small_email));

  (* Test Inline module *)
  Printf.printf "\n=== Testing Inline module ===\n";

  (* Test inline text *)
  let inline_text = Inline.text "Hello world" in
  let inline_html = Inline.to_html inline_text in
  Printf.printf "Inline.text test passed. HTML: %s\n" inline_html;

  (* Test inline bold *)
  let inline_bold = Inline.bold "Bold text" in
  let inline_bold_html = Inline.to_html inline_bold in
  Printf.printf "Inline.bold test passed. HTML: %s\n" inline_bold_html;

  (* Test inline italic *)
  let inline_italic = Inline.italic "Italic text" in
  let inline_italic_html = Inline.to_html inline_italic in
  Printf.printf "Inline.italic test passed. HTML: %s\n" inline_italic_html;

  (* Test inline link *)
  let inline_link = Inline.link ~href:"https://example.com" "Click here" in
  let inline_link_html = Inline.to_html inline_link in
  Printf.printf "Inline.link test passed. HTML: %s\n" inline_link_html;

  (* Test inline concat *)
  let inline_concat = Inline.concat [
    Inline.text "Hello ";
    Inline.bold "world";
    Inline.text "! ";
    Inline.link ~href:"https://example.com" "Click here";
  ] in
  let inline_concat_html = Inline.to_html inline_concat in
  Printf.printf "Inline.concat test passed. HTML: %s\n" inline_concat_html;

  (* Test Paragraph with inline content *)
  let rich_paragraph = Paragraph.of_inline @@ Inline.concat [
    Inline.text "Welcome ";
    Inline.bold "new user";
    Inline.text "! Please ";
    Inline.link ~href:"https://example.com/settings" "visit your settings";
  ] in
  let rich_para_elem = Paragraph.to_element rich_paragraph in
  let rich_para_html = Element.to_html rich_para_elem in
  Printf.printf "Paragraph.of_inline test passed. HTML: %s\n" rich_para_html;

  (* Test Paragraph with inline content and styling *)
  let styled_rich_paragraph = Paragraph.of_inline
    ~color:Color.Brand.gray_600
    ~font_size:Font_size.small
    @@ Inline.concat [
      Inline.text "This is ";
      Inline.italic "styled";
      Inline.text " rich text.";
    ] in
  let styled_rich_para_elem = Paragraph.to_element styled_rich_paragraph in
  let styled_rich_para_html = Element.to_html styled_rich_para_elem in
  Printf.printf "Paragraph.of_inline with styling test passed. HTML: %s\n" styled_rich_para_html;

  (* Test Heading with inline content *)
  let rich_heading = Heading.of_inline_h1 @@ Inline.concat [
    Inline.text "Welcome to ";
    Inline.bold "typemail";
  ] in
  let rich_head_elem = Heading.to_element rich_heading in
  let rich_head_html = Element.to_html rich_head_elem in
  Printf.printf "Heading.of_inline_h1 test passed. HTML: %s\n" rich_head_html;

  (* Test Heading with inline content and styling *)
  let styled_rich_heading = Heading.of_inline_h2
    ~color:Color.Brand.indigo_600
    ~text_align:Text_align.Center
    @@ Inline.concat [
      Inline.text "You're ";
      Inline.italic "invited";
      Inline.text "!";
    ] in
  let styled_rich_head_elem = Heading.to_element styled_rich_heading in
  let styled_rich_head_html = Element.to_html styled_rich_head_elem in
  Printf.printf "Heading.of_inline_h2 with styling test passed. HTML: %s\n" styled_rich_head_html;

  (* Test backward compatibility - plain text still works *)
  let plain_paragraph = Paragraph.v "Plain text paragraph" in
  let plain_para_elem = Paragraph.to_element plain_paragraph in
  let plain_para_html = Element.to_html plain_para_elem in
  Printf.printf "Paragraph.v (backward compat) test passed. HTML: %s\n" plain_para_html;

  let plain_heading = Heading.h3 "Plain text heading" in
  let plain_head_elem = Heading.to_element plain_heading in
  let plain_head_html = Element.to_html plain_head_elem in
  Printf.printf "Heading.h3 (backward compat) test passed. HTML: %s\n" plain_head_html;

  (* Test complete email with rich text *)
  let rich_email_section = Section.v [
    Heading.to_element (Heading.of_inline_h1 @@ Inline.concat [
      Inline.text "Welcome to ";
      Inline.bold "typemail";
    ]);
    Paragraph.to_element (Paragraph.of_inline @@ Inline.concat [
      Inline.text "This is a test email with ";
      Inline.italic "rich text";
      Inline.text " formatting. Visit ";
      Inline.link ~href:"https://example.com" "our website";
      Inline.text " for more info.";
    ]);
    Button.to_element (Button.v
      ~href:"https://example.com"
      ~background:(Color.solid "#4f46e5")
      ~text_color:Color.Brand.white
      ~width_px:200
      ~height_px:44
      "Get Started");
  ] in
  let rich_email = Section.to_element rich_email_section in
  match Render.render_email rich_email with
  | Ok email_html -> Printf.printf "Rich email render test passed. Length: %d bytes\n" (String.length email_html)
  | Error msg -> Printf.printf "Rich email render test failed: %s\n" msg;

  Printf.printf "\n✅ All tests passed!\n"
