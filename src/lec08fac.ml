let rec fac n = match n with
  | 0 -> 1
  | n -> n * fac (n - 1)
;;
Printf.printf "%i\n" (fac 0)


(*
  Now do:

  1. ocamlbuild -use-ocamlfind -package bisect_ppx src/lec08fac.native
  2. BISECT_COVERAGE=YES ./lec08fac.native
  3. bisect-ppx-report -I _build/src/ -html coverage/ bisect0001.out

  Step 1 compiles the code with coverage instrumentation.
  Step 2 runs the code and collects coverage information.
         This is written to the file bisect0001.out.
  Step 3 combines the code and the coverage information into an HTML report
         which is written to the coverage/ directory.

  If 'bisect0001.out' already exists (from an earlier run)
  Step 2 will not overwrite it, but instead write to 'bisect0002.out'.
  (and so on for bisect0003.out, bisect0004.out, ...)

  This means you have to either
  - delete the old .out file when rerunning or
  - adjust the filename in Step 3 above to match the latest output file.
*)
