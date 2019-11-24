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

/*
    Le prédicat reduit pour la règle rename fait:
    	- La recherche dans le programme P pour trouver toutes les occurences de X (qui est dans E)
    	- La substitution de ces X avec le terme T (Qui est dans E et qui est une variable)
    	- Puis l'ajout dans le nouveau système d'équations Q
*/

rename(X, T, Element) :-
	/*Element =.. [_| Equation],
	Equation = [X2| T2],
	echo("rename: "), echo(T2),echo("\n"),
	\+var(T2),
	!,
	T2 \== X,
	!,
	echo("rename: "), echo(Element),echo("\n"),
	T2 is T,
	echo("rename: "), echo(Element),echo("\n").*/
	X = T.



reduit(rename, E, P, Q) :-
	E =.. [_| Equation],
	Equation = [X| T],
	Q = P,
	rename(X, T, Q),
	echo(Q),
	!.

% Occur check

/*
	Si on réduit avec une occur check, on termine en indiquant que c'est impossible
*/
reduit(check, E, P, Q) :-
		echo("\n Occur check detectee \n"),
		false,
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
