build: main.byte test.byte

%.byte:
	ocamlbuild -use-ocamlfind -use-menhir -package core -cflag -thread -lflag -thread src/$@

clean:
	ocamlbuild -clean
