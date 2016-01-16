operators :- op(500, fx, if),
			 op(600, xfy, then),
             op(600, xfx, else).

:- operators.

:- dynamic def/2.
			 
cargar_fichero(File) :- see(File),
					    repeat,
						read(Term),
						(Term = end_of_file, !; 
						arg(1, Term, A),
						arg(2, Term, B),
						assert(def(A, B)),
						fail),
						seen.		

separar(Exp, A, B) :- arg(1, Exp, X),
					  arg(2, Exp, Y),
					  expresion(X, A),
					  expresion(Y, B).

expresion_aritmetica(Exp, Res) :- functor(Exp, +, _),
								  separar(Exp, A, B),
								  Res is A + B.
expresion_aritmetica(Exp, Res) :- functor(Exp, -, _),
								  separar(Exp, A, B),
								  Res is A - B.
								  
expresion_aritmetica(Exp, Res) :- functor(Exp, *, _),
								  separar(Exp, A, B),
								  Res is A * B.
								  
expresion_aritmetica(Exp, Res) :- functor(Exp, /, _),
								  separar(Exp, A, B),
								  Res is A / B.
								  
expresion_aritmetica(Exp, Res) :- functor(Exp, mod, _),
								  separar(Exp, A, B),
								  Res is A mod B.
								  
expresion_aritmetica(Exp, Res) :- number(Exp),
								  Res is Exp.

expresion_logica(Exp, Res) :- functor(Exp, =:=, _),
							  separar(Exp, A, B),
						      A =:= B, 
							  Res = 1.
							  
expresion_logica(Exp, Res) :- functor(Exp, =:=, _),
							  Res = 0.
							  
expresion_logica(Exp, Res) :- functor(Exp, >, _),
							  separar(Exp, A, B),
						      A > B, 
							  Res = 1.
							  
expresion_logica(Exp, Res) :- functor(Exp, >, _),
							  Res = 0.
							  
expresion_logica(Exp, Res) :- functor(Exp, >=, _),
							  separar(Exp, A, B),
						      A >= B, 
							  Res = 1.
							  
expresion_logica(Exp, Res) :- functor(Exp, >=, _),
							  Res = 0.
							  
expresion_logica(Exp, Res) :- functor(Exp, =<, _),
							  separar(Exp, A, B),
						      A =< B, 
							  Res = 1.
							  
expresion_logica(Exp, Res) :- functor(Exp, =<, _),
							  Res = 0.
							  
expresion_logica(Exp, Res) :- functor(Exp, <, _),
							  separar(Exp, A, B),
						      A < B, 
							  Res = 1.
							  
expresion_logica(Exp, Res) :- functor(Exp, <, _),
							  Res = 0.
							  
expresion_logica(Exp, Res) :- functor(Exp, =\=, _),
							  separar(Exp, A, B),
						      A =\= B, 
							  Res = 1.
							  
expresion_logica(Exp, Res) :- functor(Exp, =\=, _),
							  Res = 0.
								  
expresion(if A then B else _, Res) :- expresion(A, X),
									  X > 0, 
									  expresion(B, Res), !.
									  
expresion(if _ then _ else C, Res) :- expresion(C, Res), !.

expresion(Exp, Res) :- def(Exp, B),
					   expresion(B, Res), !.		

expresion(Exp, Res) :- expresion_aritmetica(Exp, Res), !.
					   
expresion(Exp, Res) :- expresion_logica(Exp, Res), !.

expresion(_, _) :- nl,
				   write('ERROR: Llamada a una funcion inexistente.'),
				   nl,
				   abort.
				   
evaluar(Exp) :- var(Exp),
			    write('ERROR: La expresion es una variable.'),
			    Exp = 0. 
			 
evaluar(Exp) :- write(Exp),
			    write(' = '),
			    expresion(Exp, Res),
			    write(Res).

exec(Exp, File) :- cargar_fichero(File),
				   evaluar(Exp).