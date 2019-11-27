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

% Unifie
%unifie(P) :-
	

% Réduit

% Rename
reduit(rename, E, P, Q) :-
	% Récupération de l'équation sur laquelle appliquer la règle
	E =.. [_| Equation],
	Equation = [X| T],
	% Unification avec la nouvelle valeur de X
	X = T,
	% Stockage du nouveau programme dans Q
	Q = P,
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
