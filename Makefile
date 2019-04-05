lec08aexp:
	ocamlbuild -use-ocamlfind -package qcheck,ppx_deriving.show,bisect_ppx src/lec08aexp.native
	BISECT_COVERAGE=YES ./lec08aexp.native
	bisect-ppx-report -I _build/src/ -html coverage/ bisect0001.out

lec08fac:
	ocamlbuild -use-ocamlfind -package bisect_ppx src/lec08fac.byte
	BISECT_COVERAGE=YES ./lec08fac.byte
	bisect-ppx-report -I _build/src/ -html coverage/ bisect0001.out

lec06:
	ocamlbuild -use-ocamlfind -package qcheck,ppx_deriving.show src/lec06.native

lec06putget: lec06putgetlib.o
	ocamlbuild -I src -use-ocamlfind -package ctypes,ctypes.foreign,qcheck,ppx_deriving.show -lflags src/lec06putgetlib.o src/lec06putget.native

lec06putgetprint: lec06putgetlib.o
	ocamlbuild -I src -use-ocamlfind -package ctypes,ctypes.foreign,qcheck,ppx_deriving.show -lflags src/lec06putgetlib.o src/lec06putgetprint.native

lec06putgetcomp: lec06putgetlib.o
	ocamlbuild -I src -use-ocamlfind -package ctypes,ctypes.foreign,qcheck,ppx_deriving.show -lflags src/lec06putgetlib.o src/lec06putgetcomp.native

lec06putgetlib.o: src/lec06putgetlib.c
	ocamlbuild src/lec06putgetlib.o

lec06putgetlib.so: src/lec06putgetlib.c
	if [[ ! -d _build ]]; then mkdir _build; fi
	if [[ ! -d _build/src ]]; then mkdir _build/src; fi
	gcc -shared -o _build/src/lec06putgetlib.so -fPIC src/lec06putgetlib.c

lec05:
	ocamlbuild -use-ocamlfind -package qcheck,ppx_deriving.show src/lec05.byte

lec05hashtable:
	ocamlbuild -use-ocamlfind -package qcheck,ppx_deriving.show src/lec05hashtable.native

lec05queue:
	ocamlbuild -use-ocamlfind -package qcheck,ppx_deriving.show src/lec05queue.native

lec04:
	ocamlbuild -use-ocamlfind -package qcheck src/lec04.byte

lec03:
	ocamlbuild -use-ocamlfind -package qcheck src/lec03.byte

lec02:
	ocamlbuild -use-ocamlfind -package qcheck src/lec02.byte

clean:
	ocamlbuild -clean
	rm -f tmp.c tmp tmp.stdout tmp.stderr bisect000*.out
