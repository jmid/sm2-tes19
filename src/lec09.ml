open QCheck

type lit =
  | Strlit of string
  | Boollit of bool
  | Intlit of int

let litgen =
  Gen.oneof
    [ Gen.map (fun s -> Strlit s) (Gen.small_string ~gen:Gen.printable);
      Gen.map (fun b -> Boollit b) Gen.bool;
      Gen.map (fun i -> Intlit i) Gen.small_signed_int ]

(** A generator based on the BNF grammar *)
module BNF =
  struct
    (* BNF expression type with traditional var representation *)
    type exp =
      | Lit of lit
      | Var of string
      | Lam of string * exp
      | App of exp * exp

    let vargen =
      let alphagen = Gen.map char_of_int (Gen.int_range (int_of_char 'a') (int_of_char 'z')) in
      Gen.map (String.make 1) alphagen

    (* a grammar-based generator *)
    let gen =
      let rec mygen gas = match gas with
        | 0 -> Gen.oneof
                 [Gen.map (fun x -> Var x) vargen;
                  Gen.map (fun l -> Lit l) litgen]
        | _ -> Gen.oneof
                 [Gen.map  (fun x -> Var x) vargen;
                  Gen.map2 (fun x e -> Lam (x,e)) vargen (mygen (gas-1));
                  Gen.map  (fun l -> Lit l) litgen;
                  Gen.map2 (fun e e' -> App (e,e')) (mygen (gas/2)) (mygen (gas/2));
                 ]
      in Gen.sized mygen
  end

(** A generator based on 'de Bruijn' indices (numbered variables) *)
module DB =
  struct
    (* expression type without variable names (de Bruijn indices) *)
    type dbexp =
      | Lit of lit
      | Var of int
      | Lam of dbexp
      | App of dbexp * dbexp

    (* a de Bruijn index generator *)
    let gen =
      (* param i:
           None   - no enclosing binders,
           Some j - j enclosing binders *)
      let rec mygen i gas = match gas with
        | 0 -> Gen.oneof
                 ((if i <> None
                   then [Gen.return (Var 0)]
                   else [])
                  @ [Gen.map (fun l -> Lit l) litgen])
        | _ -> Gen.frequency
                 ((match i with
                   | None   -> (* No vars: outside a binder *)
                               [(1, Gen.map (fun e -> Lam e) (mygen (Some 0) (gas-1)))]
                   | Some j -> [(1, Gen.map (fun j -> (Var j)) (Gen.int_range 0 j));
                                (1, Gen.map (fun e -> Lam e) (mygen (Some (j+1)) (gas-1)));])
	          @ [(1, Gen.map (fun l -> Lit l) litgen);
               (1, Gen.map2 (fun e e' -> App (e,e')) (mygen i (gas/2)) (mygen i (gas/2)));
           ])
      in Gen.sized (mygen None)
  end
