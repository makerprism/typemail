(* Automated structure validation tests *)

open Typemail

let test_count = ref 0
let passed = ref 0
let failed = ref 0

let assert_test name condition =
  incr test_count;
  if condition then (
    incr passed;
    Printf.printf "✓ %s\n" name
  ) else (
    incr failed;
    Printf.printf "✗ %s\n" name
  )

let html_contains haystack needle =
  let needle_len = String.length needle in
  let haystack_len = String.length haystack in
  let rec search pos =
    if pos + needle_len > haystack_len then false
    else if String.sub haystack pos needle_len = needle then true
    else search (pos + 1)
  in
  search 0

(* Count non-overlapping occurrences of a needle in a haystack. *)
let count_occurrences haystack needle =
  let needle_len = String.length needle in
  let haystack_len = String.length haystack in
  if needle_len = 0 then 0
  else
    let rec loop pos acc =
      if pos + needle_len > haystack_len then acc
      else if String.sub haystack pos needle_len = needle then
        loop (pos + needle_len) (acc + 1)
      else
        loop (pos + 1) acc
    in
    loop 0 0

(* Test 1: Button has VML comments *)
let test_button_vml () =
  let button = Button.v
    ~href:"https://example.com"
    ~background:(Color.solid "#4f46e5")
    ~text_color:Color.Brand.white
    ~width_px:200
    ~height_px:44
    "Click me" in

  let html = Element.to_html (Button.to_element button) in

  assert_test "Button: VML opening comment present" (html_contains html "<!--[if mso]>");
  assert_test "Button: VML v:roundrect tag present" (html_contains html "<v:roundrect");
  assert_test "Button: VML closing comment present" (html_contains html "<![endif]-->");
  assert_test "Button: Fallback table present" (html_contains html "<table")

(* Test 2: Section has gradient + fallback *)
let test_section_gradient_fallback () =
  let section = Section.make
    ~background:(Color.gradient
      ~direction:"to bottom"
      ~colors:["#667eea"; "#764ba2"]
      ~fallback:(Color.solid "#667eea"))
    ~padding:(Spacing.of_px_exn 24)
    ~children:[Heading.to_element (Heading.h3 "Test")]
    () in

  let html = Element.to_html (Section.to_element section) in

  assert_test "Section: Gradient CSS present" (html_contains html "linear-gradient");
  assert_test "Section: Fallback bgcolor present" (html_contains html "bgcolor=\"#667eea\"")

(* Test 3: Text escaping *)
let test_text_escaping () =
  let heading = Heading.h1 "<script>alert('xss')</script>" in
  let html = Element.to_html (Heading.to_element heading) in

  assert_test "Escaping: < entity escaped" (html_contains html "&lt;");
  assert_test "Escaping: Raw script NOT present" (not (html_contains html "<script>"))

(* Test 4: Required attributes *)
let test_required_attributes () =
  let img = Image.v
    ~src:"https://example.com/logo.png"
    ~alt:"Logo"
    ~width_px:200
    ~height_px:50 in

  let img_html = Element.to_html (Image.to_element img) in
  assert_test "Image: alt attribute present" (html_contains img_html "alt=\"")

(* Test: Icon with solid background renders circular bubble *)
let test_icon_bubble_solid () =
  let icon = Icon.v
    ~background:(Color.solid "#6b46c1")
    ~diameter_px:80
    ~size_px:40
    "👥" in
  let html = Element.to_html (Icon.to_element icon) in

  assert_test "Icon: border-radius 50% present"
    (html_contains html "border-radius: 50%");
  assert_test "Icon: bgcolor fallback present"
    (html_contains html "bgcolor=\"#6b46c1\"");
  assert_test "Icon: diameter width attribute present"
    (html_contains html "width=\"80\"");
  assert_test "Icon: font-size from size_px present"
    (html_contains html "font-size: 40px");
  assert_test "Icon: glyph content present"
    (html_contains html "👥")

(* Test: Icon without background renders minimal table, no bubble styling *)
let test_icon_no_background () =
  let icon = Icon.v ~size_px:32 "⭐" in
  let html = Element.to_html (Icon.to_element icon) in

  assert_test "Icon (no bg): font-size present"
    (html_contains html "font-size: 32px");
  assert_test "Icon (no bg): no border-radius"
    (not (html_contains html "border-radius"));
  assert_test "Icon (no bg): no bgcolor attribute"
    (not (html_contains html "bgcolor="));
  assert_test "Icon (no bg): glyph content present"
    (html_contains html "⭐")

(* Test: Icon validates size_px > 0 *)
let test_icon_zero_size_raises () =
  let raised =
    try
      let _ = Icon.v ~size_px:0 "X" in
      false
    with Invalid_argument _ -> true
  in
  assert_test "Icon: size_px = 0 raises Invalid_argument" raised

(* Test: Icon content is HTML-escaped *)
let test_icon_content_escaped () =
  let icon = Icon.v ~size_px:24 "<bad>" in
  let html = Element.to_html (Icon.to_element icon) in

  assert_test "Icon: escaped entity present"
    (html_contains html "&lt;bad&gt;");
  assert_test "Icon: raw tag NOT present"
    (not (html_contains html "<bad>"))

(* Test: Icon with gradient emits both bgcolor fallback and background CSS *)
let test_icon_gradient () =
  let icon = Icon.v
    ~background:(Color.gradient
      ~direction:"135deg"
      ~colors:["#7c3aed"; "#6b46c1"]
      ~fallback:(Color.solid "#6b46c1"))
    ~diameter_px:80
    ~size_px:40
    "👥" in
  let html = Element.to_html (Icon.to_element icon) in

  assert_test "Icon (gradient): bgcolor fallback present"
    (html_contains html "bgcolor=\"#6b46c1\"");
  assert_test "Icon (gradient): linear-gradient in CSS"
    (html_contains html "linear-gradient(135deg, #7c3aed, #6b46c1)")

(* Test: Section padding uniform *)
let test_section_padding_uniform () =
  let section = Section.make
    ~padding:(Spacing.of_px_exn 16)
    ~children:[]
    () in
  let html = Element.to_html (Section.to_element section) in

  assert_test "Section uniform: single padding value"
    (html_contains html "padding: 16px;")

(* Test: Section padding axes only *)
let test_section_padding_axes () =
  let section = Section.make
    ~padding_x:(Spacing.of_px_exn 40)
    ~padding_y:(Spacing.of_px_exn 32)
    ~children:[]
    () in
  let html = Element.to_html (Section.to_element section) in

  assert_test "Section axes: two-value padding shorthand"
    (html_contains html "padding: 32px 40px;")

(* Test: Section padding axis overrides uniform *)
let test_section_padding_axis_overrides_uniform () =
  let section = Section.make
    ~padding:(Spacing.of_px_exn 16)
    ~padding_x:(Spacing.of_px_exn 40)
    ~children:[]
    () in
  let html = Element.to_html (Section.to_element section) in

  assert_test "Section override: axis-specific wins"
    (html_contains html "padding: 16px 40px;")

(* Test: Section padding none *)
let test_section_padding_none () =
  let section = Section.v [] in
  let html = Element.to_html (Section.to_element section) in

  assert_test "Section none: no padding attribute"
    (not (html_contains html "padding="))

(* Test 5: Gmail limit *)
let test_gmail_limit () =
  let small = Section.v [Heading.to_element (Heading.h2 "Small")] in
  let small_html = Element.to_html (Section.to_element small) in

  assert_test "Gmail Limit: Small email within limit" (String.length small_html <= 1024 * 1024)

(* Test 6: Heading and Paragraph emit inline style, not the obsolete
   HTML4 `color` attribute. Email clients ignore the `color` attribute
   on <h1>..<h6> and <p>. *)
let test_color_uses_inline_style () =
  let h = Heading.h1 ~color:(Color.solid "#1a0933") "Hi" in
  let h_html = Element.to_html (Heading.to_element h) in
  assert_test "Heading: color uses inline style"
    (html_contains h_html "style=\"color: #1a0933;\"");
  assert_test "Heading: no legacy color= attribute"
    (not (html_contains h_html "color=\"#1a0933\""));

  let p = Paragraph.make ~color:(Color.solid "#6b7280") ~content:"Hi" () in
  let p_html = Element.to_html (Paragraph.to_element p) in
  assert_test "Paragraph: color uses inline style"
    (html_contains p_html "style=\"color: #6b7280;\"");
  assert_test "Paragraph: no legacy color= attribute"
    (not (html_contains p_html "color=\"#6b7280\""))

(* Test 7: Void elements self-close and have no closing tag. The DOCTYPE
   declares XHTML 1.0 Transitional, which requires `<img />` / `<hr />`. *)
let test_void_elements_self_close () =
  let img = Image.v ~src:"https://example.com/x.png" ~alt:"X"
      ~width_px:40 ~height_px:40 in
  let img_html = Element.to_html (Image.to_element img) in
  assert_test "Image: renders self-closing <img ... />"
    (html_contains img_html "/>");
  assert_test "Image: no invalid </img> closing tag"
    (not (html_contains img_html "</img>"));

  let div = Divider.v () in
  let div_html = Element.to_html (Divider.to_element div) in
  assert_test "Divider: renders self-closing <hr ... />"
    (html_contains div_html "/>");
  assert_test "Divider: no invalid </hr> closing tag"
    (not (html_contains div_html "</hr>"))

(* Test 8: Column's inner table wraps children in <tr><td> so block
   elements are not direct children of <table> (invalid HTML that
   Outlook drops). *)
let test_column_wraps_children_in_tr_td () =
  let col = Column.v [
    Image.to_element (Image.v ~src:"https://example.com/x.png" ~alt:"X"
                        ~width_px:40 ~height_px:40);
    Heading.to_element (Heading.h1 "Hi");
  ] in
  let html = Element.to_html (Column.to_element col) in
  assert_test "Column: inner table has <tr><td> wrapper"
    (html_contains html "<tr><td>");
  assert_test "Column: no naked <img> as direct table child"
    (not (html_contains html "presentation\"><img"));
  assert_test "Column: no naked <h1> as direct table child"
    (not (html_contains html "presentation\"><h1"))

(* Test 9: render_email conditional comments close cleanly on one line.
   A stray newline between `<` and `![endif]-->` breaks the Outlook
   downlevel-hidden conditional-comment contract. *)
let test_conditional_comments_are_single_line () =
  let body = Section.v [Heading.to_element (Heading.h1 "Hi")] in
  match Render.render_email (Section.to_element body) with
  | Error e -> assert_test (Printf.sprintf "render_email succeeds: %s" e) false
  | Ok html ->
    assert_test "render_email: <![endif]--> appears on one line"
      (html_contains html "<![endif]-->");
    assert_test "render_email: no split `<\\n![endif]-->`"
      (not (html_contains html "<\n![endif]-->"))

(* Test 10: Paragraph.v emits no style attribute *)
let test_paragraph_v_no_style () =
  let p = Paragraph.v "Plain text." in
  let html = Element.to_html (Paragraph.to_element p) in

  assert_test "Paragraph.v: renders <p> tag" (html_contains html "<p");
  assert_test "Paragraph.v: no style attribute present" (not (html_contains html "style="));
  assert_test "Paragraph.v: content preserved" (html_contains html "Plain text.")

(* Test 11: Paragraph.make with color only *)
let test_paragraph_color_only () =
  let p = Paragraph.make
    ~color:(Color.solid "#ff0000")
    ~content:"Red text."
    () in
  let html = Element.to_html (Paragraph.to_element p) in

  assert_test "Paragraph color-only: style contains color" (html_contains html "style=\"color: #ff0000;\"");
  assert_test "Paragraph color-only: no font-size" (not (html_contains html "font-size"));
  assert_test "Paragraph color-only: no font-style" (not (html_contains html "font-style"));
  assert_test "Paragraph color-only: no text-align" (not (html_contains html "text-align"));
  assert_test "Paragraph color-only: no legacy color= attribute" (not (html_contains html "color=\""))

(* Test 12: Paragraph.make with font_size only *)
let test_paragraph_font_size_only () =
  let p = Paragraph.make
    ~font_size:Font_size.small
    ~content:"Small text."
    () in
  let html = Element.to_html (Paragraph.to_element p) in

  assert_test "Paragraph font_size-only: style contains font-size" (html_contains html "style=\"font-size: 13px;\"");
  assert_test "Paragraph font_size-only: no color" (not (html_contains html "color:"))

(* Test 13: Paragraph.make with all four fields combined *)
let test_paragraph_all_fields () =
  let p = Paragraph.make
    ~color:(Color.solid "#333333")
    ~font_size:Font_size.large
    ~font_style:Font_style.Italic
    ~text_align:Text_align.Center
    ~content:"Styled."
    () in
  let html = Element.to_html (Paragraph.to_element p) in

  assert_test "Paragraph all-fields: single style attribute" (html_contains html "style=\"color: #333333; font-size: 20px; font-style: italic; text-align: center;\"");
  (* Only one style= occurrence *)
  let first = String.index html '"' in
  let rest = String.sub html (first + 1) (String.length html - first - 1) in
  let second_style = html_contains rest "style=" in
  assert_test "Paragraph all-fields: exactly one style attribute" (not second_style)

(* Test 14: Heading.make with font_size *)
let test_heading_font_size () =
  let h = Heading.make
    ~level:Heading.H2
    ~font_size:Font_size.xlarge
    ~content:"Hero heading"
    () in
  let html = Element.to_html (Heading.to_element h) in

  assert_test "Heading.make font_size: emits h2 tag" (html_contains html "<h2");
  assert_test "Heading.make font_size: style contains font-size" (html_contains html "style=\"font-size: 24px;\"")

(* Test 15: Heading.h1 ~color backward-compat (uses the same make path) *)
let test_heading_h1_color_backward_compat () =
  let h = Heading.h1 ~color:Color.Brand.white "Welcome" in
  let html = Element.to_html (Heading.to_element h) in

  assert_test "Heading.h1 ~color: emits h1 tag" (html_contains html "<h1");
  assert_test "Heading.h1 ~color: style contains color" (html_contains html "style=\"color: #ffffff;\"");
  assert_test "Heading.h1 ~color: no legacy color= attribute" (not (html_contains html "color=\""))

(* Test 16: Font_size.of_px boundary behavior *)
let test_font_size_boundaries () =
  assert_test "Font_size.of_px 8: Some (at lower bound)" (Font_size.of_px 8 <> None);
  assert_test "Font_size.of_px 7: None (below lower bound)" (Font_size.of_px 7 = None);
  assert_test "Font_size.of_px 72: Some (at upper bound)" (Font_size.of_px 72 <> None);
  assert_test "Font_size.of_px 73: None (above upper bound)" (Font_size.of_px 73 = None)

(* Test 17: Text_align.Center renders correctly *)
let test_text_align_center () =
  let p = Paragraph.make
    ~text_align:Text_align.Center
    ~content:"Centered"
    () in
  let html = Element.to_html (Paragraph.to_element p) in

  assert_test "Text_align.Center: renders text-align: center" (html_contains html "text-align: center;");
  assert_test "Text_align.to_css Center is \"center\"" (Text_align.to_css Text_align.Center = "center");
  assert_test "Text_align.to_css Left is \"left\"" (Text_align.to_css Text_align.Left = "left");
  assert_test "Text_align.to_css Right is \"right\"" (Text_align.to_css Text_align.Right = "right")

(* Test 18: Footer string shortcut still renders as before *)
let test_footer_string_shortcut () =
  let footer = Footer.v "© 2024 Example" in
  let html = Element.to_html (Footer.to_element footer) in

  assert_test "Footer (string): table wrapper present" (html_contains html "<table");
  assert_test "Footer (string): td cell present" (html_contains html "<td");
  assert_test "Footer (string): text content rendered" (html_contains html "© 2024 Example")

(* Test 19: Footer.of_children renders each child inside the footer cell *)
let test_footer_of_children () =
  let footer = Footer.of_children [
    Paragraph.to_element (Paragraph.v "line 1");
    Paragraph.to_element (Paragraph.v "line 2");
  ] in
  let html = Element.to_html (Footer.to_element footer) in

  assert_test "Footer (children): first paragraph rendered" (html_contains html "line 1");
  assert_test "Footer (children): second paragraph rendered" (html_contains html "line 2");
  assert_test "Footer (children): paragraph tags present" (html_contains html "<p")

(* Test 20: Footer.make with ~children works and honors background *)
let test_footer_make_children () =
  let footer = Footer.make
    ~background:(Color.solid "#1f2937")
    ~children:[
      Paragraph.to_element (Paragraph.v "© 2024 Example");
      Divider.to_element (Divider.v ());
    ]
    () in
  let html = Element.to_html (Footer.to_element footer) in

  assert_test "Footer (make ~children): background applied"
    (html_contains html "bgcolor=\"#1f2937\"");
  assert_test "Footer (make ~children): child content rendered"
    (html_contains html "© 2024 Example")

(* Test 21: Footer.make with no content and no children raises Invalid_argument *)
let test_footer_make_requires_body () =
  let raised =
    try
      let _ = Footer.make () in
      false
    with Invalid_argument _ -> true
  in
  assert_test "Footer (make): empty call raises Invalid_argument" raised

(* Test 22: Footer.make prefers children over content when both are given *)
let test_footer_make_children_wins () =
  let footer = Footer.make
    ~content:"ignored text"
    ~children:[Paragraph.to_element (Paragraph.v "visible child")]
    () in
  let html = Element.to_html (Footer.to_element footer) in

  assert_test "Footer (make): children win over content"
    (html_contains html "visible child" && not (html_contains html "ignored text"))

(* Test 23: Callout with background + accent renders two <td>s with accent bgcolor on the first *)
let test_callout_background_and_accent () =
  let callout = Callout.v
    ~background:(Color.solid "#f3f0ff")
    ~accent:(Color.solid "#6b46c1")
    [Paragraph.to_element (Paragraph.v "Heads up")] in

  let html = Element.to_html (Callout.to_element callout) in

  assert_test "Callout: two <td>s rendered when accent set"
    (count_occurrences html "<td " = 2);
  assert_test "Callout: accent bgcolor on accent cell"
    (html_contains html "bgcolor=\"#6b46c1\"");
  assert_test "Callout: accent cell is 4px wide"
    (html_contains html "width=\"4\"" && html_contains html "width: 4px");
  assert_test "Callout: background bgcolor on table"
    (html_contains html "bgcolor=\"#f3f0ff\"");
  (* Regression: Color.to_style already includes the `background-color: ` prefix,
     so the call sites in Callout.to_element must not add another one. *)
  assert_test "Callout: table style is non-doubled background-color"
    (html_contains html "style=\"background-color: #f3f0ff;\"");
  assert_test "Callout: accent cell style is non-doubled background-color"
    (html_contains html
       "style=\"width: 4px; background-color: #6b46c1; font-size: 0; line-height: 0;\"");
  assert_test "Callout: no doubled background-color: prefix"
    (not (html_contains html "background-color: background-color:"))

(* Test 24: Callout with background only (no accent) renders a single <td> with background *)
let test_callout_background_only () =
  let callout = Callout.v
    ~background:(Color.solid "#eef2ff")
    [Paragraph.to_element (Paragraph.v "Tip content")] in

  let html = Element.to_html (Callout.to_element callout) in

  assert_test "Callout (bg only): single <td> rendered"
    (count_occurrences html "<td " = 1);
  assert_test "Callout (bg only): background bgcolor present"
    (html_contains html "bgcolor=\"#eef2ff\"");
  assert_test "Callout (bg only): no accent width attribute"
    (not (html_contains html "width=\"4\""));
  assert_test "Callout (bg only): table style is non-doubled background-color"
    (html_contains html "style=\"background-color: #eef2ff;\"");
  assert_test "Callout (bg only): no doubled background-color: prefix"
    (not (html_contains html "background-color: background-color:"))

(* Test 25: Callout with a gradient background preserves the gradient style
   emitted by Color.to_style (no extra prefix wrapping). *)
let test_callout_gradient_background () =
  let callout = Callout.v
    ~background:(Color.gradient
      ~direction:"to bottom"
      ~colors:["#faf5ff"; "#ede9fe"]
      ~fallback:(Color.solid "#faf5ff"))
    [Paragraph.to_element (Paragraph.v "Gradient callout")] in

  let html = Element.to_html (Callout.to_element callout) in

  assert_test "Callout (gradient): gradient style emitted verbatim"
    (html_contains html
       "style=\"background: linear-gradient(to bottom, #faf5ff, #ede9fe); background-color: #faf5ff;\"");
  assert_test "Callout (gradient): fallback bgcolor present"
    (html_contains html "bgcolor=\"#faf5ff\"");
  assert_test "Callout (gradient): no doubled background-color: prefix"
    (not (html_contains html "background-color: background-color:"))

(* Test 26: Callout with accent only (no background) renders accent cell but no table-level bgcolor *)
let test_callout_accent_only () =
  let callout = Callout.make
    ~accent:(Color.solid "#dc2626")
    ~children:[Paragraph.to_element (Paragraph.v "Warning")]
    () in

  let html = Element.to_html (Callout.to_element callout) in

  assert_test "Callout (accent only): two <td>s rendered"
    (count_occurrences html "<td " = 2);
  assert_test "Callout (accent only): accent bgcolor on accent cell"
    (html_contains html "bgcolor=\"#dc2626\"");
  (* Exactly one bgcolor attribute (on the accent cell), none at the table level. *)
  assert_test "Callout (accent only): no table-level background color"
    (count_occurrences html "bgcolor=" = 1);
  (* The only background-color in the output comes from the accent cell's inline
     style; the table itself must carry no background-color style. *)
  assert_test "Callout (accent only): table tag has no style attribute"
    (not (html_contains html "<table style="));
  assert_test "Callout (accent only): accent cell style is non-doubled background-color"
    (html_contains html
       "style=\"width: 4px; background-color: #dc2626; font-size: 0; line-height: 0;\"");
  assert_test "Callout (accent only): no doubled background-color: prefix"
    (not (html_contains html "background-color: background-color:"))

(* Test 27: Children render inside the content <td> *)
let test_callout_children_rendered () =
  let callout = Callout.v
    ~background:(Color.solid "#f5f5f5")
    ~accent:(Color.solid "#111827")
    [Paragraph.to_element (Paragraph.v "Distinctive paragraph content")] in

  let html = Element.to_html (Callout.to_element callout) in

  assert_test "Callout: child paragraph text is rendered"
    (html_contains html "Distinctive paragraph content");
  assert_test "Callout: child paragraph <p> tag is rendered"
    (html_contains html "<p")

(* Test 28: make () with neither background nor accent raises Invalid_argument *)
let test_callout_requires_background_or_accent () =
  let raised =
    try
      let _ = Callout.make ~children:[] () in
      false
    with
    | Invalid_argument _ -> true
    | _ -> false
  in
  assert_test "Callout: make() with neither background nor accent raises Invalid_argument"
    raised

let () =
  Printf.printf "\n=== typemail Structure Tests ===\n\n";
  test_button_vml ();
  test_section_gradient_fallback ();
  test_text_escaping ();
  test_required_attributes ();
  test_icon_bubble_solid ();
  test_icon_no_background ();
  test_icon_zero_size_raises ();
  test_icon_content_escaped ();
  test_icon_gradient ();
  test_section_padding_uniform ();
  test_section_padding_axes ();
  test_section_padding_axis_overrides_uniform ();
  test_section_padding_none ();
  test_gmail_limit ();
  test_color_uses_inline_style ();
  test_void_elements_self_close ();
  test_column_wraps_children_in_tr_td ();
  test_conditional_comments_are_single_line ();
  test_paragraph_v_no_style ();
  test_paragraph_color_only ();
  test_paragraph_font_size_only ();
  test_paragraph_all_fields ();
  test_heading_font_size ();
  test_heading_h1_color_backward_compat ();
  test_font_size_boundaries ();
  test_text_align_center ();
  test_footer_string_shortcut ();
  test_footer_of_children ();
  test_footer_make_children ();
  test_footer_make_requires_body ();
  test_footer_make_children_wins ();
  test_callout_background_and_accent ();
  test_callout_background_only ();
  test_callout_gradient_background ();
  test_callout_accent_only ();
  test_callout_children_rendered ();
  test_callout_requires_background_or_accent ();

  Printf.printf "\n=== Summary ===\n";
  Printf.printf "Total: %d | Passed: %d | Failed: %d\n" !test_count !passed !failed;

  if !failed = 0 then
    (Printf.printf "\n✅ All tests passed!\n"; exit 0)
  else
    (Printf.printf "\n❌ Some tests failed\n"; exit 1)
