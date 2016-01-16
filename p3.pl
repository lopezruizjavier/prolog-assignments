use_package(dynamic_clauses, aggregates).

:- dynamic movimiento/1.
:- dynamic comprobado/2.
:- dynamic corte/1.
:- dynamic ultimos_cortes/1.

:- assert(movimiento([])).
:- assert(ultimos_cortes([])).

append([], Y, Y).
append([H | T], Y, [H | Z]) :- append(T, Y, Z).

member(X, [X | _]).
member(X, [_ | T]) :- member(X, T).  

last(X, [X]).
last(X, [_ | Z]) :- last(X, Z).   

same([]).
same([_]).
same([X, X| T]) :- same([X | T]).                                                                                                                                 

replace(_, _, [], []).
replace(O, R, [O|T], [R|T2]) :- replace(O, R, T, T2).
replace(O, R, [H|T], [H|T2]) :- H \= O, 
                                replace(O, R, T, T2).

reverse([], X, X).
reverse([H | T], X, R) :- reverse(T, [H | X], R). 

get_lista([H-L | _], H, L).
get_lista([_ | T], I, X) :- get_lista(T, I, X).

numero_palancas(X, N) :- functor(X, palancas, N).

intercambiar(off, on).
intercambiar(on, off).

copiar_palanca(X, Y, I) :- arg(I, X, A), 
                           arg(I, Y, A).

cambiar_palanca(X, Y, I) :- arg(I, X, A), 
                            intercambiar(A, B), 
                            arg(I, Y, B).

copiar_o_cambiar(Inicio, Fin, Palanca, Cambio, _) :- Palanca = Cambio,
                                                   cambiar_palanca(Inicio, Fin, Palanca).
copiar_o_cambiar(Inicio, Fin, Palanca, Cambio, Movimientos) :- get_lista(Movimientos, Cambio, X),
                                                             member(Palanca, X),
                                                             cambiar_palanca(Inicio, Fin, Palanca).                                            
copiar_o_cambiar(Inicio, Fin, Palanca, _, _) :- copiar_palanca(Inicio, Fin, Palanca).

mover_palanca_aux(Inicio, Fin, Palanca, Cambio, Movimientos) :- Palanca > 0,
                                                                copiar_o_cambiar(Inicio, Fin, Palanca, Cambio, Movimientos), 
                                                                A is Palanca - 1,
                                                                mover_palanca_aux(Inicio, Fin, A, Cambio, Movimientos).                                           
mover_palanca_aux(_, _, _, _, _).

mover_palanca(Inicio, Fin, Palanca, Movimientos) :- numero_palancas(Inicio, N),
                                                    numero_palancas(Fin, N),
                                                    mover_palanca_aux(Inicio, Fin, N, Palanca, Movimientos), 
                                                    !.

mover_palancas(Inicio, Fin, _, []) :- Fin = Inicio, 
                                      !.                                                    
mover_palancas(Inicio, Fin, Movimientos, [H | T]) :- mover_palanca(Inicio, Y, H, Movimientos),
                                                     mover_palancas(Y, Fin, Movimientos, T).

siguiente_movimiento_aux2([N | T], A, R, N) :- siguiente_movimiento_aux2(T, [1 | A], R, N).
siguiente_movimiento_aux2([H | T], A, R, _) :- H2 is H + 1, 
                                               reverse(T, [H2 | A], R).

siguiente_movimiento_aux(X, N, M) :- same([N | M]),
                                     replace(N, 1, [N | M], X).

siguiente_movimiento_aux(X, N, M) :- reverse(M, [], L),
                                     siguiente_movimiento_aux2(L, [], X, N).

siguiente_movimiento(X, N) :- movimiento(M), 
                              siguiente_movimiento_aux(X, N, M), 
                              !,
                              retract(movimiento(M)),
                              assert(movimiento(X)).                        

meter_corte(H, _) :- ultimos_cortes([]), 
                     retract(ultimos_cortes([])), 
                     assert(ultimos_cortes([H])), 
                     !.
meter_corte(H, _) :- ultimos_cortes([C | T]), 
                     not(member(H, [C | T])), 
                     retract(ultimos_cortes(_)), 
                     assert(ultimos_cortes([H | [C | T]])), 
                     !.
meter_corte(H, N) :- ultimos_cortes(C), 
                     length(C, L), 
                     L = N, 
                     last(T, C), 
                     T = H, 
                     retract(ultimos_cortes(_)), 
                     assert(ultimos_cortes([H | C])), 
                     !.
meter_corte(_, _).                    

cortar_rama_aux([], _).
cortar_rama_aux([H | X], [H | Y]) :- cortar_rama_aux(X, Y).
cortar_rama_aux(_, _) :- fail.

cortar_rama(S) :- corte(X), 
                  cortar_rama_aux(X, S), !.

no_cortar_rama([H | T], N) :- cortar_rama([H | T]), 
                              meter_corte(H, N), 
                              !, 
                              fail.  
no_cortar_rama(_, _).

poner_corte(Solucion, Palancas) :- retract(ultimos_cortes(_)), 
                                   assert(ultimos_cortes([])), 
                                   comprobado(X, Palancas), 
                                   !, 
                                   ground(X), 
                                   assert(corte(Solucion)).                                   
poner_corte(Solucion, Palancas) :- assert(comprobado(Solucion, Palancas)).            

nueva_solucion(Inicial, Final, Movimientos, Solucion) :- numero_palancas(Inicial, N),
                                                         siguiente_movimiento(Solucion, N),
                                                         no_cortar_rama(Solucion, N),  
                                                         mover_palancas(Inicial, F, Movimientos, Solucion),
                                                         poner_corte(Solucion, F),
                                                         Final = F.

abrir(Inicial, Inicial, _, []) :- !.
abrir(Inicial, Final, Movimientos, Solucion) :- reiniciar,
                                                repeat, 
                                                (nueva_solucion(Inicial, Final, Movimientos, Solucion), 
                                                 poner_corte(Solucion, Final); 
                                                    numero_palancas(Inicial, N),
                                                    ultimos_cortes(C),
                                                    length(C, L),
                                                    L > N,
                                                    fin).

fin :- write('Ya no hay mas soluciones.'), 
       nl, 
       reiniciar,
       abort.

reiniciar :- retract(movimiento(_)),
             assert(movimiento([])),
             retract(ultimos_cortes(_)),
             assert(ultimos_cortes([])), 
             retractall(comprobado(_, _)), 
             retractall(corte(_)).

minima(Inicial, Final, Movimientos, Solucion) :- abrir(Inicial, Final, Movimientos, Solucion).