%{
open Dockerfile
%}
%token <string> RUN
%token <string> FROM
%token <string> MAINTAINER
%token <string> ENV
%token <string> ADD
%token EOF

%start <Dockerfile.commands option> dockerfile

%%

dockerfile:
  | hs = header; cmds = lines; EOF { Some {header=hs; commands=cmds;} }
  | EOF { None }
  ;


header:
  | h = FROM  { Dockerfile.header_of_pair h None }
  | h = FROM; m = MAINTAINER { Dockerfile.header_of_pair h (Some m) }
  ;


lines: l = rev_lines { List.rev l };


rev_lines:
  | c = one_command  { c :: [] }
  | l = rev_lines; c = one_command { c :: l }
  ;

one_command:
  | c = RUN   { `Run c }
  | c = ENV   { `Env c }
  | c = ADD   { `Add c }
  ;
