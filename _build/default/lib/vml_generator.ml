(** VML fallback generation for Outlook. *)

let bulletproof_button ~width_px ~height_px ~background ~text_color ~border_radius ~content ~href =
  (* background and text_color are now CSS strings *)
  let bg_color = background in
  let text_color_hex = text_color in

  (* Build VML for Outlook *)
  let border_radius_attr = match border_radius with
    | None -> ""
    | Some r -> Printf.sprintf " arcsize=\"%d%%\"" r
  in

  (* Outlook-specific VML markup *)
  let vml_start = Printf.sprintf
    "<!--[if mso]>
      <v:roundrect xmlns:v=\"urn:schemas-microsoft-com:vml\"
                  xmlns:w=\"urn:schemas-microsoft-com:office:word\"
                  href=\"%s\"
                  style=\"width:%dpx;height:%dpx;\"
                  arcsize=\"0%%\"
                  strokeweight=\"0px\"
                  %s
                  fillcolor=\"%s\">
        <w:anchorlock/>
        <center>
        <![endif]-->" href width_px height_px border_radius_attr bg_color in

  let vml_end = "<!--[if mso]></center></v:roundrect><![endif]-->" in

  (* Fallback HTML for modern clients *)
  let button_html = Printf.sprintf
    "<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"margin:0;padding:0;\">
      <tr>
        <td style=\"background-color:%s;border-radius:%dpx;display:inline-block;height:%dpx;width:%dpx;text-align:center;vertical-align:middle;\">
          <a href=\"%s\" style=\"background-color:%s;border-radius:%dpx;color:%s;display:inline-block;font-family:sans-serif;font-size:16px;font-weight:bold;line-height:%dpx;text-align:center;text-decoration:none;width:%dpx;-webkit-text-size-adjust:none;mso-hide:all;\">%s</a>
        </td>
      </tr>
    </table>"
    bg_color
    (Option.value ~default:0 border_radius)
    height_px
    width_px
    href
    bg_color
    (Option.value ~default:0 border_radius)
    text_color_hex
    height_px
    width_px
    content

  in
  (* Combine VML + fallback *)
  let full_html = vml_start ^ button_html ^ vml_end in

  (* Return as text node since this is pre-rendered HTML *)
  Html_builder.text full_html
