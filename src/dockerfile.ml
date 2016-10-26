type header = {from: string; maintainer: string option}
[@@deriving show]

type commands = {
    header: header;
    commands: [
      | `Run of string
      | `Env of string
      | `Add of string
      ] list
  }
[@@deriving show]

let header_of_pair from maintainer = { from; maintainer }
