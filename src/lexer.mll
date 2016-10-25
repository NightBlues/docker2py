{
open Lexing
open Parser

exception Error of string
}


let newline = '\n'
let white = [' ' '\t' '\n']+
let command = [^ ' ' '\t' '\n']+ [^ '\n' ]*
let comment = "#" [^'\n']* '\n'?



rule read =
  parse
  | white { read lexbuf }
  | comment { read lexbuf }
  | "RUN" { RUN (read_command lexbuf) }
  | "FROM" { FROM (read_command lexbuf) }
  | "MAINTAINER" { MAINTAINER (read_command lexbuf) }
  | "ENV" { ENV (read_command lexbuf) }
  | "ADD" { ADD (read_command lexbuf) }
  | _ { raise (Error ("Unexpected char: " ^ Lexing.lexeme lexbuf)) }
  | eof { EOF }

and read_command =
  parse
  | white { read_command lexbuf }
  | command { Lexing.lexeme lexbuf }
  | _ {raise (Error ("Command finished with new line expected: " ^ Lexing.lexeme lexbuf))}
