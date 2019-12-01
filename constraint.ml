
let print_constraint ff (n, init, table) =
  let k = List.length init in
  let var_at t i =
    assert (0 <= t && t <= k);
    assert (t <= i && i < 3 * k - t);
    "x_" ^ string_of_int t ^ "_" ^ string_of_int i
  in
  Format.fprintf ff "@[<v>include \"table.mzn\";@,";
  for t = 0 to k do
    for i = t to 3 * k - t - 1 do
      Format.fprintf ff "var 0..%d: %s;@," (n - 1) (var_at t i)
    done
  done;
  List.iteri (fun i st -> Format.fprintf ff "constraint %s == %d;@," (var_at k (i + k)) st) init;
  Format.fprintf ff "set of int: LINES = 1..%d;@,set of int: COLS = 1..4;@,array[LINES,COLS] of int: transition =@,[|" (List.length table);
  List.iteri (fun i ((x1, x2, x3), y) ->
      if i > 0 then Format.fprintf ff " |";
      Format.fprintf ff "%2d, %2d, %2d, %2d@," x1 x2 x3 y
    ) table;
  Format.fprintf ff " |];@,";
  for t = 1 to k do
    for i = t to 3 * k - t - 1 do
      Format.fprintf ff "constraint table([%s, %s, %s, %s], transition);@,"
        (var_at (t - 1) (i - 1)) (var_at (t - 1) i) (var_at (t - 1) (i + 1)) (var_at t i)
    done
  done;
  Format.fprintf ff "solve satisfy;@,";
  Format.fprintf ff "output [\"initial state:%t\"];@]@." (fun ff -> for i = 0 to 3 * k - 1 do Format.fprintf ff " \\(%s)" (var_at 0 i) done)
