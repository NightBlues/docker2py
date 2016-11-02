open Dockerfile
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
  let template_name = dockerfile.header.from in
  Pythonlib.Ast.Expr
    (Pythonlib.Ast.Call
       (Pythonlib.Ast.Name ("create_template", Pythonlib.Ast.Load, pos),
        [Pythonlib.Ast.Str (template_name, pos)], [], None, None, pos),
     pos)

let create_template dockerfile =
  let mymod =
    let a = Lexing.dummy_pos in
    Pythonlib.Ast.Module
      ([
          (get_maintainer dockerfile);
          (get_template dockerfile)
        ],
       a)
  in
  Pythonlib.Pretty.print_mod mymod
