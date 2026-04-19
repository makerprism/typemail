(** Main rendering pipeline. *)

let gmail_limit_bytes = 1024 * 1024  (* 102KB = 1024 * 1024 bytes *)

let within_gmail_limit html =
  String.length html <= gmail_limit_bytes

let render_html element =
  let html = Element.to_html element in
  if within_gmail_limit html then
    Ok html
  else
    let size = String.length html in
    let size_kb = size / 1024 in
    Error (Printf.sprintf "Email size %dKB exceeds Gmail's 102KB limit" size_kb)

let render_email ?(body_background = Color.solid "#ffffff") element =
  (* Render the body content *)
  let body_html = Element.to_html element in

  (* Check size limit *)
  if not (within_gmail_limit body_html) then
    let size = String.length body_html in
    let size_kb = size / 1024 in
    Error (Printf.sprintf "Email size %dKB exceeds Gmail's 102KB limit" size_kb)
  else
    (* Build body background style and attributes *)
    let background_style = Color.to_style body_background in
    let base_style = "margin: 0; padding: 0; word-spacing: normal;" in
    let full_style = base_style ^ " " ^ background_style in

    (* Add bgcolor attribute for Outlook gradient fallback.
       Gradients are not supported in Outlook Windows (2007-2019), so we
       provide a solid fallback color via the bgcolor attribute.
       This is extracted from the gradient's fallback field, which is
       guaranteed to be a Solid color through the Color API. *)
    let bgcolor_attr = match body_background with
      | Color.Solid hex -> Printf.sprintf " bgcolor=\"%s\"" hex
      | Color.Gradient {fallback; _} ->
          (* Extract the solid fallback color, traversing nested gradients if needed *)
          let rec extract_solid_fallback = function
            | Color.Solid hex -> hex
            | Color.Gradient {fallback; _} -> extract_solid_fallback fallback
          in
          Printf.sprintf " bgcolor=\"%s\"" (extract_solid_fallback fallback)
    in

    (* Build complete email document *)
    let email_html = Printf.sprintf
      {|<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta name="x-apple-disable-message-reformatting" />
  <!--[if mso]>
  <noscript>
    <xml>
      <o:OfficeDocumentSettings>
        <o:PixelsPerInch>96</o:PixelsPerInch>
      </o:OfficeDocumentSettings>
    </xml>
  </noscript>
  <![endif]-->
  <title>Email</title>
  <!--[if mso]>
  <style>
    table { border-collapse: collapse; }
    td, th, div, p, a, h1, h2, h3, h4, h5, h6 { font-family: Arial, sans-serif; }
  </style>
  <![endif]-->
</head>
<body%s style="%s">
%s
</body>
</html>|} bgcolor_attr full_style body_html in
    Ok email_html
