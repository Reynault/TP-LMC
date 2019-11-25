% Fichier dans lequel j'avance de mon côté

% Opérateur ?=

:- op(20,xfy,?=).




% Prédicats d'affichage fournis

% set_echo: ce prédicat active l'affichage par le prédicat echo
set_echo :- assert(echo_on).

% clr_echo: ce prédicat inhibe l'affichage par le prédicat echo
clr_echo :- retractall(echo_on).

% echo(T): si le flag echo_on est positionné, echo(T) affiche le terme T
%          sinon, echo(T) réussit simplement en ne faisant rien.

echo(T) :- echo_on, !, write(T).
echo(_).


% Réduit

% Rename
reduit(rename, E, P, Q) :-
	% Récupération de l'équation sur laquelle appliquer la règle
	E =.. [_| Equation],
	Equation = [X| T],
	% Application du renommage
	rename(X, T, P, Q),
	!.

rename(X, T, [Element, Programme], Q) :-
	Element =.. [_| Equation],
	Equation = [X2| T2],
	%var(T2),
	%T2 == X,
	echo(Programme),
	echo(Q),
	Q = [X2 ?= T| Q],
	rename(X, T, Programme,  Q),
	!.

rename(_, _, [], _) :-
	% Programme vide
	!.

/*
reduit(simplify, E, P, Q) :-

    .

reduit(expand, E, P, Q) :-

    .

reduit(orient, E, P, Q) :-

    .

reduit(clash, E, P, Q) :-

    .
*/
