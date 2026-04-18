(** Example: Collaboration invitation email

    This example demonstrates how to compose a transactional email
    using typemail's typed components.
*)

open Typemail

let invitation_email ~inviter_name ~presence_name ~invitation_url =
  (* Build the email content using typed components *)
  let email_body = Section.v [
    (* Header section with gradient background *)
    Section.to_element @@ Section.make
      ~background:(Color.gradient
        ~direction:"to bottom"
        ~colors:["#312e81"; "#4f46e5"]
        ~fallback:(Color.solid "#312e81"))
      ~padding:(Spacing.Spacing.px32)
      ~children:[
        Heading.to_element @@ Heading.h1 ~color:Color.Brand.white
          (Printf.sprintf "You're invited to %s" presence_name);
        Paragraph.to_element @@ Paragraph.v ~color:Color.Brand.white
          (Printf.sprintf "%s has invited you to collaborate." inviter_name);
      ]
      () ;

    (* Main content section *)
    Section.to_element @@ Section.make
      ~padding:(Spacing.Spacing.px24)
      ~children:[
        Heading.to_element @@ Heading.h2 "Get started today";
        Paragraph.to_element @@ Paragraph.v
          "Join your team and start collaborating in real-time.";
        Paragraph.v ~color:Color.Brand.gray_500
          "Click the button below to accept your invitation.";

        (* Call-to-action button with VML for Outlook *)
        Button.to_element @@ Button.v
          ~href:invitation_url
          ~background:(Color.solid "#4f46e5")
          ~text_color:Color.Brand.white
          ~width_px:200
          ~height_px:44
          "Accept invitation";
      ]
      () ;

    (* Footer section *)
    Footer.to_element @@ Footer.v
      ~background:(Color.solid "#1f2937")
      (Printf.sprintf "© 2024 %s. All rights reserved." presence_name);
  ] in

  (* Render the complete email *)
  match Render.render_email email_body with
  | Ok email_html -> email_html
  | Error msg ->
      Printf.printf "Error rendering email: %s\n" msg;
      ""

let () =
  (* Example usage *)
  let html = invitation_email
    ~inviter_name:"Alice"
    ~presence_name:"Acme Social"
    ~invitation_url:"https://example.com/invite/abc" in

  (* Print the result *)
  print_endline html;

  (* Check size *)
  Printf.printf "\nEmail size: %d bytes\n" (String.length html);
  Printf.printf "Gmail limit: %s\n"
    (if String.length html <= Render.gmail_limit_bytes
     then "✅ Within limit"
     else "❌ Exceeds limit")
