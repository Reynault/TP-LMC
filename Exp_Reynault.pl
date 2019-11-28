% Fichier dans lequel j'avance de mon côté

% Opérateur ?=

:- op(20,xfy,?=).


% récupérer arguments : arg(numéro, nom de la fonction, variable où stocker le résultat)
% à tester: compoud(T)

% Prédicats d'affichage fournis

% set_echo: ce prédicat active l'affichage par le prédicat echo
set_echo :- assert(echo_on).

% clr_echo: ce prédicat inhibe l'affichage par le prédicat echo
clr_echo :- retractall(echo_on).

% echo(T): si le flag echo_on est positionné, echo(T) affiche le terme T
%          sinon, echo(T) réussit simplement en ne faisant rien.

echo(T) :- echo_on, !, write(T).
echo(_).

% ------------------------------------

% Occur check
/*
    Si on compare (V) a une variable (T) alors on sait que V ne peut pas se trouver dans le 
    terme T car c'est une variable on peux donc stoper le test d'occurence.
    Si V != T et que T n'est pas une variable (donc un terme) alors on peux stopper l'execution, 
    car les deux sont différents.
*/
occur_check(V, T) :-
    var(T),!,
    V \== T,
    !.

/*
    Si T est un terme alors il faut parcourir ses éléments afin de vérifier que V ne se trouve pas dedans.
    On transforme alors T en liste et on parcours la liste.
*/
occur_check(V, T):-
    T =.. [ _| Termes],
    occur_check_parcours(V, Termes).

/*
    Prédicat qui permet de mettre fin à la récurrence quand la liste est vide.
*/
occur_check_parcours(_, []) :-
    !.

/*
    Prédicat de parcours d'une liste de paramètres qu'il faut alors tester un à un.
*/
occur_check_parcours(V, [Element | Termes]):-
    occur_check(V, Element),
    occur_check_parcours(V, Termes).
	
% ------------------------------------

% Unifie
%unifie(P) :-

% Réduit

% Rename/ Expand/ Simplify

/*
	Prédicat réduit pour la règle rename, il applique le renommage sur
	le programme P en fonction de l'équation E, et rend le résultat
	dans Q
*/
reduit(rename, E, [_| P], Q) :-
	elimination(E, P, Q),
	!.

/*
	Prédicat réduit pour la règle expand, il applique l'extension sur
	le programme P en fonction de l'équation E, et rend le résultat
	dans Q
*/
reduit(expand, E, [_| P], Q) :-
	elimination(E, P, Q),
	!.

/*
	Prédicat réduit pour la règle simplify, il applique la simplification sur
	le programme P en fonction de l'équation E, et rend le résultat
	dans Q
*/
reduit(simplify, E, [_| P], Q) :-
	elimination(E, P, Q),
	!.

/*
	Prédicat elimination qui permet d'appliquer l'unification permettant d'appliquer
	les règles rename, expand et simplify
*/
elimination(E, P, Q) :-
	% Récupération de l'équation sur laquelle appliquer la règle
	E =.. [_| Equation],
	Equation = [X| T],
	% Unification avec la nouvelle valeur de X
	X = T,
	% Q devient alors le reste du programme
	Q = P,
	!.

% Decompose

/*
	Prédicat reduit qui permet d'appliquer la règle decompose sur l'équation E.
	On ajout alors au programme P les nouvelles équations, le résultat est placé dans Q. 
*/
reduit(decompose, E, [_| P], Q) :-
	% Récupération des paramètres
	E =.. [_| Equation],
	Equation = [Fonc1| T],
	T = [Fonc2| _],
	% Récupération des arguments
	Fonc1 =.. [_| Param1],
	Fonc2 =.. [_| Param2],

	% Ajout des nouvelles équations
	decompose(Param1, Param2, Liste),
	% Ajout de la liste dans le programme P
	append(P, Liste, Q),
	!.

decompose([Arg1| Args1], [Arg2| Args2], Liste) :-
	append(Liste, [Arg1 ?= Arg2], New),
	decompose(Args1, Args2, Liste),
	!.

decompose([], [], Liste) :-
	echo("fin"),
	echo(Liste),
	!.


reduit(orient, E, [_| P], Q) :-
	% Récupération des paramètres
	E =.. [_| Equation],
	Equation = [T| Variable],
	Variable = [X| _],

	append(P, [X ?= T], Q),
	!.