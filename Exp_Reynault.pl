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


%construct(E, P, Q).

/*
    Chercher l'équation qui possède dans sa partie gauche, la variable T (Récupération de la partie droite)

    Renommer E par la variable de cette équation

    Mettre à jour le système d'équation Q (P avec changement)
*/
/*reduit(rename, E, P, Q) :-
    E =.. [_| V],
    V = [X| T],
    echo(X), echo(" ?= "), echo(T),
    recup(ToFind, Program, Right),
    T is D,
    construct(E, P, Q),
    !.
*/

recup(ToFind, Program, Right) :-
    Program = [Equation| _],
    Equation =.. [_| V],
    V = [X| T],
    X = ToFind,
    var(T),
    Right = T,
    !.

recup(ToFind, Program, Right) :-
    Program = [_| System],
    recup(ToFind, System, Right),
    !.

/*
reduit(simplify, E, P, Q) :-

    .

reduit(expand, E, P, Q) :-

    .

reduit(check, E, P, Q) :-

    !.

reduit(orient, E, P, Q) :-

    .

reduit(decompose, E, P, Q) :-

    .

reduit(clash, E, P, Q) :-

    .
*/
