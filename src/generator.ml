open Dockerfile
open Pythonlib

let pos = Lexing.dummy_pos

let get_maintainer dockerfile =
  let maintainer =
    match dockerfile.header.maintainer with
    | None -> ""
    | Some m -> m
  in
  let maintainer = "Maintainer: " ^ maintainer in
  Pythonlib.Ast.Expr (Pythonlib.Ast.Str (maintainer, pos), pos)

let get_template dockerfile =
  let distrib, release = dockerfile.header.from in
  let open Pythonlib.Ast in
  let create_container_func = Name ("create_container", Load, pos) in
  let create_container_args = [Str (distrib, pos); Str (release, pos)] in
  let create_container_call =
    Call (create_container_func, create_container_args, [], None, None, pos)
  in
  Assign
    ([Name ("container", Load, pos)],
     create_container_call,
     pos)

let get_command = function
  | `Run cmd ->
     Pythonlib.Ast.Expr
       (Pythonlib.Ast.Call
          (Pythonlib.Ast.Name ("run", Pythonlib.Ast.Load, pos),
           [Pythonlib.Ast.Name ("container", Pythonlib.Ast.Load, pos);
            Pythonlib.Ast.Str (cmd, pos)], [], None, None, pos),
        pos)
  | _ ->
     Pythonlib.Ast.Expr (Pythonlib.Ast.Name ("None", Pythonlib.Ast.Load, pos), pos)

let rec get_commands acc = function
  | hd :: tl -> get_commands (get_command hd :: acc) tl
  | [] -> acc


let create_template dockerfile =
  let mymod =
    let a = Lexing.dummy_pos in
    Pythonlib.Ast.Module
      ([
          (get_maintainer dockerfile);
          (get_template dockerfile)
        ] @ List.rev (get_commands [] dockerfile.commands),
       a)
  in
  Pythonlib.Pretty.print_mod mymod; Format.fprintf Format.std_formatter "\n"
