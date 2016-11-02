{
open Lexing
open Parser

exception Error of string
}


let newline = '\n'
let white = [' ' '\t' '\n']+
let comment = "#" [^'\n']* '\n'?



rule read =
  parse
  | white { read lexbuf }
  | comment { read lexbuf }
  | "RUN" { RUN (read_command [] lexbuf) }
  | "FROM" { let release, distrib = read_from lexbuf, read_from lexbuf in FROM (distrib, release) }
  | "MAINTAINER" { MAINTAINER (read_command [] lexbuf) }
  | "ENV" { ENV (read_command [] lexbuf) }
  | "ADD" { ADD (read_command [] lexbuf) }
  | _ { raise (Error ("Unexpected char: " ^ Lexing.lexeme lexbuf)) }
  | eof { EOF }

and read_command acc =
  parse
  | [^ '\\' '\n']+ { read_command ((Lexing.lexeme lexbuf)::acc) lexbuf }
  | '\\' '\n' { read_command acc lexbuf }
  | '\n' | eof { String.concat "" (List.rev acc) |> String.trim }
  | _ {raise (Error ("Command finished with new line expected: " ^ Lexing.lexeme lexbuf))}

and read_from =
  parse
  | [^ ':' '\n']+ { Lexing.lexeme lexbuf |> String.trim}
  | ':' { read_from lexbuf }
  | _ {raise (Error ("From field must be in form distrib:release at " ^ Lexing.lexeme lexbuf))}
