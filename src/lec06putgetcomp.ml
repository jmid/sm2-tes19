open QCheck

module PGConf =
struct
  type cmd = Put of int | Get [@@deriving show { with_path = false }]
  type state = int
  type sut = out_channel (* was: unit *)

  let arb_cmd s =
    let int_gen = Gen.oneof [Gen.map Int32.to_int int32.gen; Gen.small_int] in
    QCheck.make ~print:show_cmd
      (Gen.oneof [Gen.map (fun i -> Put i) int_gen; Gen.return Get])
      
  let init_state  = 0
  let next_state c s = match c with
    | Put i -> i
    | Get   -> s

  let init_sut () = (let ostr = open_out "tmp.c" in
                     Printf.fprintf ostr "#include <assert.h>\n";
                     Printf.fprintf ostr "int main() {\n";
                     ostr)
  let cleanup ostr = (Printf.fprintf ostr " return 0;\n";
                      Printf.fprintf ostr "}\n";
                      flush ostr;
                      close_out ostr)
  let run_cmd c s ostr = match c with
    | Put i -> (Printf.fprintf ostr " put(%i);\n" i; true)
    | Get   -> (Printf.fprintf ostr " assert(get () == %i);\n" s; true)

  let precond _ _ = true
end
module PGtest = QCSTM.Make(PGConf)

(* Caveat: the built-in list shrinker simply tries to remove one element per shrink, 
   which is too inefficient for large counterexample lists.
   Here I've therefore rolled my own, which first cuts the list in half
   and secondly falls back to removing single elements (e.g., in the middle) *)
let list_shk ?shrink l yield =
  let len = List.length l in
  let rec halve l r l_len =
    if len/2 = 0 then () else
      match r with
       | [] -> ()
       | x :: r' ->
         if l_len = len - len/2 then (yield (List.rev l); yield r)
         else halve (x::l) r' (l_len+1)
  in
  halve [] l 0;
  let rec rm_single l r = match r with
    | [] -> ()
    | x :: r' ->
      yield (List.rev_append l r');
      rm_single (x::l) r'
  in
    rm_single [] l
  

let t =
  Test.make ~name:"compiled putget" ~count:500
    (set_shrink list_shk
       (PGtest.arb_cmds PGConf.init_state)) (* generator of commands *)
    (fun cs ->
       let ostr = PGConf.init_sut () in
       ignore(PGtest.interp_agree PGConf.init_state ostr cs);
       PGConf.cleanup ostr;
       (* now compile and run program, checking exit codes *)
       0 = Sys.command ("gcc -Wall -Wextra -pedantic -Wno-implicit-function-declaration src/lec06putgetlib.c tmp.c -o tmp")
         && 0 = Sys.command ("exec 2>tmp.stderr; ./tmp 1>tmp.stdout"))
;;
QCheck_runner.run_tests ~verbose:true [t]
