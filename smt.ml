
let print_smt ~use_function ~use_inductive ~produce_model ff (n, init, table) =
  let k = List.length init in
  let var_at t i =
    assert (0 <= t && t <= k);
    assert (t <= i && i < 3 * k - t);
    "x_" ^ string_of_int t ^ "_" ^ string_of_int i
  in
  Format.fprintf ff "@[<v>";
  if produce_model then
    Format.fprintf ff "(set-option :produce-models true)@,";
  if use_inductive then begin
    Format.fprintf ff "(set-logic ALL)@,";
    Format.fprintf ff "(declare-datatypes ( (States 0) ) ((";
    for i = 0 to n - 1 do
      Format.fprintf ff "(state_%d)" i
    done;
    Format.fprintf ff ")))@,"
  end else begin
    Format.fprintf ff "(set-logic QF_UF)@,";
    Format.fprintf ff "(declare-sort States 0)@,";
    for i = 0 to n - 1 do
      Format.fprintf ff "(declare-const state_%d States)@," i
    done;
    Format.fprintf ff "(assert (distinct";
    for i = 0 to n - 1 do
      Format.fprintf ff " state_%d" i
    done;
    Format.fprintf ff "))@,"
  end;
  for t = 0 to k do
    for i = t to 3 * k - t - 1 do
      Format.fprintf ff "(declare-const %s States)@," (var_at t i);
      if not use_inductive then begin
        Format.fprintf ff "(assert (or";
        for st = 0 to n - 1 do
          Format.fprintf ff " (= %s state_%d)" (var_at t i) st
        done;
        Format.fprintf ff "))@,"
      end
    done
  done;
  List.iteri (fun i st -> Format.fprintf ff "(assert (= %s state_%d))@," (var_at k (i + k)) st) init;
  if use_function then begin
    Format.fprintf ff "(declare-fun transition (States States States) States)@,";
    List.iter (fun ((x1, x2, x3), y) ->
        Format.fprintf ff "(assert (= state_%d (transition state_%d state_%d state_%d)))@," y x1 x2 x3
      ) table
  end;
  for t = k downto 1 do
    for i = t to 3 * k - t - 1 do
      if use_function then begin
        Format.fprintf ff "(assert (= %s (transition %s %s %s)))@," (var_at t i) (var_at (t - 1) (i - 1)) (var_at (t - 1) i) (var_at (t - 1) (i + 1))
      end else begin
        List.iter (fun ((x1, x2, x3), y) ->
            Format.fprintf ff "(assert (=> (and (= %s state_%d) (= %s state_%d) (= %s state_%d)) (= %s state_%d)))@,"
              (var_at (t - 1) (i - 1)) x1 (var_at (t - 1) i) x2 (var_at (t - 1) (i + 1)) x3 (var_at t i) y
          ) table
      end
    done
  done;
  Format.fprintf ff "(check-sat)@,";
  if produce_model then
    Format.fprintf ff "(get-model)@,";
  Format.fprintf ff "@]@."
