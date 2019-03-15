lec05:
	ocamlbuild -use-ocamlfind -package qcheck,ppx_deriving.show src/lec05.byte

lec04:
	ocamlbuild -use-ocamlfind -package qcheck src/lec04.byte

lec03:
	ocamlbuild -use-ocamlfind -package qcheck src/lec03.byte

lec02:
	ocamlbuild -use-ocamlfind -package qcheck src/lec02.byte

clean:
	ocamlbuild -clean
