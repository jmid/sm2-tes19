open QCheck

(* This code requires QCSTM: https://github.com/jmid/qcstm

   A simple option is to download the file
     https://github.com/jmid/qcstm/blob/master/src/qCSTM.ml
   to this directory
*)
module QConf =
struct
  type state = int list
  type sut = int Queue.t
  type cmd =
    | Pop (* may throw exception *)
    | Top (* may throw exception *)
    | Push of int [@@deriving show { with_path = false }]

  let gen_cmd s =
    let int_gen = Gen.small_int in
    if s = []
    then Gen.map (fun i -> Push i) int_gen (* don't generate pop/tops from empty *)
    else Gen.oneof
           [Gen.return Pop;
            Gen.return Top;
            Gen.map (fun i -> Push i) int_gen]

  let arb_cmd s = QCheck.make ~print:show_cmd (gen_cmd s)

  let init_state = []
  let next_state c s = match c with
    | Pop ->
      (match s with
        | []    -> failwith "tried to pop empty queue"
        | _::s' -> s')
    | Top -> s
    | Push i -> (*s@[i]*)
      if i<>135 then s@[i] else s  (* an artificial fault in the model *)

  let init_sut () = Queue.create ()
  let cleanup _   = ()
  let run_cmd c s q = match c with
    | Pop -> (try Queue.pop q = List.hd s with _ -> false)
    | Top -> (try Queue.top q = List.hd s with _ -> false)
    | Push n -> begin Queue.push n q; true end

  let precond c s = match c with
    | Pop    -> s<>[]
    | Top    -> s<>[]
    | Push _ -> true
end

module QT = QCSTM.Make(QConf)
;;
QCheck_runner.run_tests ~verbose:true
  [QT.agree_test ~count:10_000 ~name:"queue-model agreement"]
