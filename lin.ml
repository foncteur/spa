
let print_glpk ff (n, init, table) =
  let k = List.length init in
  let var_at t i =
    assert (0 <= t && t <= k);
    assert (t <= i && i < 3 * k - t);
    "x_" ^ string_of_int t ^ "_" ^ string_of_int i
  in
  let var_at_st t i st =
    assert (0 <= st && st < n);
    var_at t i ^ "_" ^ string_of_int st
  in
  Format.fprintf ff "@[<v>Minimize@,  f: ";
  for i = 0 to 3 * k - 1 do
    for st = 0 to n - 1 do
      if i > 0 || st > 0 then Format.fprintf ff " + ";
      Format.fprintf ff "%s" (var_at_st 0 i st)
    done
  done;
  Format.fprintf ff "@,@,Subject To@[<v 2>";
  List.iteri (fun i s -> Format.fprintf ff "@,init_%d: %s = 1" i (var_at_st k (i + k) s)) init;
  for t = 0 to k do
    for i = t to 3 * k - t - 1 do
      Format.fprintf ff "@,unique_state_%d_%d: " t i;
      for st = 0 to n - 1 do
        if st > 0 then
          Format.fprintf ff " + ";
        Format.fprintf ff "%s" (var_at_st t i st)
      done;
      Format.fprintf ff " = 1";
      if t > 0 then
        List.iter (fun ((x1, x2, x3), y) ->
            Format.fprintf ff "@,transition_%d_%d_%d_%d_%d: " t i x1 x2 x3;
            Format.fprintf ff "%s + %s + %s - %s <= 2" (var_at_st (t - 1) (i - 1) x1) (var_at_st (t - 1) i x2) (var_at_st (t - 1) (i + 1) x3) (var_at_st t i y)
          ) table
    done
  done;
  Format.fprintf ff "@]@,@,@[<v 2>Binary";
  for t = 0 to k do
    for i = t to 3 * k - t - 1 do
      for st = 0 to n - 1 do
        Format.fprintf ff "@,%s" (var_at_st t i st)
      done
    done
  done;
  Format.fprintf ff "@]@,@,End@]@."
