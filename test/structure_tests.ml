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

let () =
  Printf.printf "\n=== typemail Structure Tests ===\n\n";
  test_button_vml ();
  test_section_gradient_fallback ();
  test_text_escaping ();
  test_required_attributes ();
  test_gmail_limit ();
  test_color_uses_inline_style ();
  test_void_elements_self_close ();
  test_column_wraps_children_in_tr_td ();
  test_conditional_comments_are_single_line ();

  Printf.printf "\n=== Summary ===\n";
  Printf.printf "Total: %d | Passed: %d | Failed: %d\n" !test_count !passed !failed;

  if !failed = 0 then
    (Printf.printf "\n✅ All tests passed!\n"; exit 0)
  else
    (Printf.printf "\n❌ Some tests failed\n"; exit 1)
