
let readlines (ic : in_channel) : string Seq.t =
  let rec aux () =
    match input_line ic with
    | line -> if line = "" || line.[0] = '#' then aux () else Seq.Cons (line, aux)
    | exception End_of_file -> Seq.Nil
  in
  aux

let parse_line (s : string) : ((string * string * string) * string) list =
  let mktoken starti i =
    String.sub s starti (i - starti + 1)
  in
  let rec tokenize starti i =
    if i >= String.length s || s.[i] = '#' then
      if starti < i then
        mktoken starti (i - 1) :: []
      else
        []
    else if s.[i] = ' ' || s.[i] = '\n' || s.[i] = '\t' then
      if starti < i then
        mktoken starti (i - 1) :: tokenize (i + 1) (i + 1)
      else
        tokenize (i + 1) (i + 1)
    else if i >= starti + 1 && s.[i - 1] = '-' && s.[i] = '>' then
      let a = "->" :: tokenize (i + 1) (i + 1) in
      if i > starti + 1 then mktoken starti (i - 2) :: a else a
    else
      tokenize starti (i + 1)
  in
  let l = tokenize 0 0 in
  match l with
  | [] -> []
  | [a; b; c; "->"; d] -> [((a, b, c), d)]
  | _ -> failwith ("Badly formed rule: \"" ^ s ^ "\"")

module SMap = Map.Make(String)

let validate states init table =
  let stm, n = List.fold_left (fun (m, i) s -> (SMap.add s i m, i + 1)) (SMap.empty, 0) states in
  let get st =
    try SMap.find st stm with Not_found -> failwith ("State '" ^ st ^ "' does not exist")
  in
  let seen = Array.init n (fun _ -> Array.init n (fun _ -> Array.make n false)) in
  let r = List.map (fun ((a, b, c), d) ->
      let ia, ib, ic = get a, get b, get c in
      let id = get d in
      if seen.(ia).(ib).(ic) then
        failwith ("A rule already exists for " ^ a ^ " " ^ b ^ " " ^ c);
      seen.(ia).(ib).(ic) <- true;
      ((ia, ib, ic), id)
    ) table in
  for i = 0 to n - 1 do
    for j = 0 to n - 1 do
      for k = 0 to n - 1 do
        if not seen.(i).(j).(k) then begin
          let a = List.nth states i in
          let b = List.nth states j in
          let c = List.nth states k in
          failwith ("No rule declared for " ^ a ^ " " ^ b ^ " " ^ c)
        end
      done
    done
  done;
  List.map get init, r

let uncons s =
  match s () with
  | Seq.Cons (x, s) -> (x, s)
  | _ -> assert false


let parse filename =
  let ic = open_in filename in
  let lines = readlines ic in
  let states, lines = uncons lines in
  let states = String.split_on_char ' ' states in
  let init, lines = uncons lines in
  let init = String.split_on_char ' ' init in
  let table = Fun.protect ~finally:(fun () -> close_in ic) (fun () -> List.concat (List.of_seq (Seq.map parse_line (readlines ic)))) in
  let init, t = validate states init table in
  (List.length states, init, t)
