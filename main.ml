
let handle_lin () =
  assert (Sys.argv.(1) = "lp");
  assert (Array.length Sys.argv = 3);
  let name = Sys.argv.(2) in
  let (n, init, table) = Parse.parse name in
  Format.printf "%a" Lin.print_glpk (n, init, table)

let handle_smt () =
  assert (Sys.argv.(1) = "smt");
  assert (Array.length Sys.argv >= 3);
  let name = Sys.argv.(Array.length Sys.argv - 1) in
  let use_function = ref false in
  let use_inductive = ref false in
  let produce_model = ref false in
  for i = 2 to Array.length Sys.argv - 2 do
    match Sys.argv.(i) with
    | "--use-function" -> use_function := true
    | "--use-inductive" -> use_inductive := true
    | "--produce-model" -> produce_model := true
    | _ -> failwith "Unknown option"
  done;
  let (n, init, table) = Parse.parse name in
  Format.printf "%a" (Smt.print_smt ~use_function:!use_function ~use_inductive:!use_inductive ~produce_model:!produce_model) (n, init, table)

let handle_constraint () =
  assert (Sys.argv.(1) = "constraint");
  assert (Array.length Sys.argv = 3);
  let name = Sys.argv.(2) in
  let (n, init, table) = Parse.parse name in
  Format.printf "%a" Constraint.print_constraint (n, init, table)

let main () =
  assert (Array.length Sys.argv >= 2);
  match Sys.argv.(1) with
  | "lp" -> handle_lin ()
  | "smt" -> handle_smt ()
  | "constraint" -> handle_constraint ()
  | _ -> failwith "Unknown subcommand"

let () = main ()
