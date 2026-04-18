(** Color values with cross-client fallback enforcement. *)

type t =
  | Solid of string
  | Gradient of {
      direction: string;
      colors: string list;
      fallback: t;
    }

(** Smart constructors for common brand colors *)
module Brand = struct
  let indigo_900 = Solid "#312e81"
  let indigo_600 = Solid "#4f46e5"
  let white = Solid "#ffffff"
  let black = Solid "#000000"
  let gray_100 = Solid "#f3f4f6"
  let gray_200 = Solid "#e5e7eb"
  let gray_300 = Solid "#d1d5db"
  let gray_400 = Solid "#9ca3af"
  let gray_500 = Solid "#6b7280"
end

let solid hex = Solid hex

let gradient ~direction ~colors ~fallback =
  Gradient {direction; colors; fallback}

let fallback = function
  | Solid _ as color -> color
  | Gradient {fallback; _} -> fallback

let to_css = function
  | Solid hex -> hex
  | Gradient {direction; colors; _} ->
      let color_list = String.concat ", " colors in
      Printf.sprintf "linear-gradient(%s, %s)" direction color_list

let to_style color =
  match color with
  | Solid hex -> Printf.sprintf "background-color: %s;" hex
  | Gradient {direction; colors; fallback = Solid fb_hex} ->
      let color_list = String.concat ", " colors in
      Printf.sprintf "background: linear-gradient(%s, %s); background-color: %s;"
        direction color_list fb_hex
  | Gradient {fallback = Gradient _; _} ->
      (* This should be impossible through the API, but handle gracefully *)
      "background-color: #ffffff;"
