lec03:
	ocamlbuild -use-ocamlfind -package qcheck src/lec03.byte

lec02:
	ocamlbuild -use-ocamlfind -package qcheck src/lec02.byte

clean:
	ocamlbuild -clean
