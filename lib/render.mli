(** Main rendering pipeline.

    Transforms typed element tree into cross-client HTML string.
    Checks Gmail 102KB limit and returns error if exceeded.

    Example:
    {[
      let email =
        Section.v [
          Heading.h1 "Welcome";
          Paragraph.v "Get started today";
        ] in
      match render_html email with
      | Ok html -> print_endline html
      | Error msg -> Printf.printf "Error: %s\n" msg
    ]}
*)

(** Render element to HTML string.

    @param element The element tree to render
    @return Ok html on success, Error message if Gmail limit exceeded
*)
val render_html : Element.t -> (string, string) Result.t

(** Render element as complete email document.

    Includes doctype, HTML wrapper, and email-specific meta tags.
    Checks Gmail 102KB limit before returning.

    @param body_background Optional background color for the <body> element.
                           Defaults to solid white (#ffffff).
                           Gradients are supported with proper fallback.
    @param element The email body content
    @return Ok complete email HTML on success, Error message if limit exceeded
*)
val render_email :
  ?body_background:Color.t ->
  Element.t ->
  (string, string) Result.t

(** Gmail size limit in bytes (102KB) *)
val gmail_limit_bytes : int

(** Check if rendered HTML exceeds Gmail limit.

    @param html The HTML string to check
    @return true if within limit, false if exceeds
*)
val within_gmail_limit : string -> bool
