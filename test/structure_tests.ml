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

let () =
  Printf.printf "\n=== typemail Structure Tests ===\n\n";
  test_button_vml ();
  test_section_gradient_fallback ();
  test_text_escaping ();
  test_required_attributes ();
  test_gmail_limit ();

  Printf.printf "\n=== Summary ===\n";
  Printf.printf "Total: %d | Passed: %d | Failed: %d\n" !test_count !passed !failed;

  if !failed = 0 then
    (Printf.printf "\n✅ All tests passed!\n"; exit 0)
  else
    (Printf.printf "\n❌ Some tests failed\n"; exit 1)
