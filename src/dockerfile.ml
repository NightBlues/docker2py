type header = {from: string; maintainer: string option}
type commands = {
    header: header;
    commands: [
      | `Run of string
      | `Env of string
      | `Add of string
      ] list;
  }

let header_of_pair from maintainer = { from; maintainer }

let pprint file =
  print_endline ("FROM " ^ file.header.from);
  ( match file.header.maintainer with
    | Some m -> print_endline ("MAINTAINER " ^ m)
    | None -> ());
  print_endline "---";
  let rec loop = function
    | `Run cmd :: tl -> print_endline ("RUN " ^ cmd); loop tl
    | `Env cmd :: tl -> print_endline ("ENV " ^ cmd); loop tl
    | `Add cmd :: tl -> print_endline ("ADD " ^ cmd); loop tl
    | [] -> ()
  in
  loop file.commands
