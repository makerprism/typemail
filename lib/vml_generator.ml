open Element
open Element.Private

(** Build bulletproof button as structured Element tree.
    VML comments are inserted as Comment nodes for proper rendering.
    All user input is escaped through Element.text.
*)
let bulletproof_button ~width_px ~height_px ~background ~text_color ~border_radius ~content ~href =
  let border_radius_attr = match border_radius with
    | None -> ""
    | Some r -> Printf.sprintf " arcsize=\"%d%%\"" r
  in

  let vml_start = Private.comment (Printf.sprintf
    "[if mso]>\
      <v:roundrect xmlns:v=\"urn:schemas-microsoft-com:vml\"\
                  xmlns:w=\"urn:schemas-microsoft-com:office:word\"\
                  href=\"%s\"\
                  style=\"width:%dpx;height:%dpx;\"\
                  arcsize=\"0%%\"\
                  strokeweight=\"0px\"\
                  %s\
                  fillcolor=\"%s\">\
        <w:anchorlock/>\
        <center>\
        <![endif]" href width_px height_px border_radius_attr background)

  and vml_end = Private.comment "[if mso]></center></v:roundrect><![endif]" in

  (* Build fallback button table *)
  let border_radius_px = match border_radius with None -> 0 | Some r -> r in

  let link_style = Printf.sprintf
    "background-color:%s;border-radius:%dpx;color:%s;display:inline-block;font-family:sans-serif;font-size:16px;font-weight:bold;line-height:%dpx;text-align:center;text-decoration:none;width:%dpx;-webkit-text-size-adjust:none;mso-hide:all;"
    background border_radius_px text_color height_px width_px in

  let td_style = Printf.sprintf
    "background-color:%s;border-radius:%dpx;display:inline-block;height:%dpx;width:%dpx;text-align:center;vertical-align:middle;"
    background border_radius_px height_px width_px in

  let fallback_table =
    make @@ builder
      ~tag:"table"
      ~attributes:[
        "cellpadding", "0";
        "cellspacing", "0";
        "border", "0";
        "style", "margin:0;padding:0;"
      ]
      ~children:[
        make @@ builder
          ~tag:"tr"
          ~attributes:[]
          ~children:[
            make @@ builder
              ~tag:"td"
              ~attributes:["style", td_style]
              ~children:[
                make @@ builder
                  ~tag:"a"
                  ~attributes:["href", href; "style", link_style]
                  ~children:[text content]
              ]
          ]
      ]
  in

  (* Wrap everything in a div and combine VML + fallback *)
  make @@ builder
    ~tag:"div"
    ~attributes:["style", "display:inline-block;"]
    ~children:[vml_start; fallback_table; vml_end]
