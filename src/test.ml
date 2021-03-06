open Core.Std

let parse_dockerfile filename () =
  let fin = open_in filename in
  let lbuf = Lexing.from_channel fin in
  let rec loop () =
    let open Parser in
    match (Lexer.read lbuf) with
    | FROM (d, r) -> print_endline (Printf.sprintf "FROM %s:%s" d r); loop ()
    | MAINTAINER c -> print_endline (Printf.sprintf "MAINTAINER %s" c); loop ()
    | RUN c -> print_endline (Printf.sprintf "RUN %s" c); loop ()
    | ENV c -> print_endline (Printf.sprintf "ENV %s" c); loop ()
    | ADD c -> print_endline (Printf.sprintf "ADD %s" c); loop ()
    (* | NL -> print_endline "NL"; loop () *)
    | EOF -> print_endline "EOF"
  in
  loop ();
  let fin = open_in filename in
  let lbuf = Lexing.from_channel fin in
  let parsed_value =
    try
      Parser.dockerfile (Lexer.read) lbuf
    with
    | Lexer.Error msg -> Printf.fprintf stderr "%s (at pos %d)\n" msg (Lexing.lexeme_start lbuf); None
    | Parser.Error -> Printf.fprintf stderr "Syntax error at pos %d\n%!"
                                     (Lexing.lexeme_start lbuf); None
  in
  match parsed_value with
  | None -> print_endline "Nothing parsed"
  | Some v -> print_endline (Dockerfile.show_commands v)

let () =
  let spec =
    (let open Command.Spec in
     empty +> anon ("filename" %: string)) in
  Command.run
    (Command.basic
       ~summary:"Parse Dockerfile"
       spec
       parse_dockerfile)
