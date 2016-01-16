size([], 0).
size([_ | Y], s(I)) :- size(Y, I).

le(0, _).
le(s(X), s(Y)) :- le(X, Y).

matrix([], 0).
matrix([X | []], S) :- size(X, S), le(s(0), S).
matrix([X | Y], S) :-  size(X, S), le(s(0), S), matrix(Y, S).

check_matrix(X) :- matrix(X, _).

row_aux([X | _], s(0), X).
row_aux([_ | Y], s(I), X) :-  row_aux(Y, I, X).
row(X, N, C) :- row_aux(X, N, C).

column(X, N, C) :- transpose(X, Y), row(Y, N, C).

first_column_aux([], [], []).
first_column_aux([[] | _], [], []).
first_column_aux([[X | []] | Z], [X | C], []) :- first_column_aux(Z, C, []).
first_column_aux([[X | Y] | Z], [X | C], [Y | R]) :- first_column_aux(Z, C, R).
first_column(X, C, R) :- first_column_aux(X, C, R).

transpose_aux([[] | _], []).
transpose_aux([[X | Y] | Z], [C | R]) :- first_column([[X | Y] | Z], C, [Y | T]), transpose_aux([Y | T], R).
transpose(X, Y) :- transpose_aux(X, Y).


symmetrical(X) :- transpose(X, X).

symmetrical_aux(X, I) :- size(X, I).
symmetrical_aux(X, I) :- row(X, I, Y), column(X, I, Y), symmetrical_aux(X, s(I)).
symmetrical2(X) :- symmetrical_aux(X, s(0)).