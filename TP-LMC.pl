/* TP - Logique - Groupe : Julien Romary, Reynault Sies

Syntax:
consult('TP-LMC.pl').*/



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




% Question n°1

% regle

/*regle( f(a) ?= f(b), rename ).
regle( f(a) ?= f(b), simplify ).
regle( f(a) ?= f(b), expand ).
regle( f(a) ?= f(b), check ).
regle( f(a) ?= f(b), orient ).
regle( f(a) ?= f(b), decompose ).
regle( f(a) ?= f(b), clash ).*/
/*
regle(A ?= B, decompose).

regle( f(A) ?= f(B), decompose ) :-
    regle( A ?= B , decompose ).

regle( f(A, X) ?= f(B, Y), decompose) :-
    regle(X ?= Y, decompose), regle(f(A) ?= f(B), decompose), echo(A).
*/


% test si orient peux etre applique sur les deux parametres
% si il peux etre appliqué alors on ne va pas plus loin, on va deja
% appliquer cette regle
regle(T ?= X, orient) :-
    nonvar(T), var(X),
    echo("\n Orient peux etre appliquer sur: \n\t"),
    echo(T), echo(" ?= "), echo(X),
    !.

% test si simplifie peux etre applique sur les deux parametres
% si il peux etre appliqué alors on ne va pas plus loin, on va deja
% appliquer cette regle
regle(X ?= T, simplify) :-
    var(X), atomic(T),
    echo("\n simplify peux etre appliquer sur: \n\t"),
    echo(X), echo(" ?= "), echo(T),
    !.

% ... autres regles ...


% test d'occurence (Vrai si on passe le test)
/*
si on compare (V) a une variable (T) alors on sait que V ne peut pas se trouver dans le terme T car c'est une variable on peux donc stoper le test d'occurence.
Si V != T et que T n'est pas une variable (donc un terme) alors on peux stopper l'execution, car les deux sont different.
*/
occur_check(V, T) :-
    var(T),!,
    V \== T,!.
/*
si T est un therme alors il faut parcourir ses element affin de verifier que V ne se trouve pas dedans.
on cast alors T en list et on parcours la list
*/
occur_check(V,T):-
    T =.. [ _| Termes].










unifie([X ?= Y | Z]) :-
    regle([X ?= Y | Z], decompose).
unifie([X ?= Y | Z]) :-
    regle([X ?= Y | Z], orient).

unifie(Z) :-
    echo(Z).

regle([Func1 ?= Func2 | Z], decompose) :-
    \+var(Func1),
    \+var(Func2),
    Func1 =.. [X | Terms1],
    Func2 =.. [Y | Terms2],
    X = Y,
    echo(X), echo(" ?= "), echo(Y), echo("\n"),
    echo(Terms1), echo(Terms2),
    not(length(Terms1, 0)),
    not(length(Terms2, 0)),
    same_size_list(Terms1, Terms2).

regle([X ?= Y | Z], orient) :-
    not(var(X)),
    unifie([Y ?= X | Z]).

same_size_list([], []).

same_size_list([_|L1], [_|L2]) :-
    same_size_list(L1, L2).





unifie(Func1, Func2):-
    \+var(Func1),
    \+var(Func2),
    Func1 =.. [X | Terms1],
    Func2 =.. [Y | Terms2],
    X = Y,
    echo(X), echo(Terms1),
    echo(Y), echo(Terms2),
    test(Terms1, Terms2).

test([X|Y], [W|Z]):-
    unifie(X, W),
    test(Y, Z).

test(X, Y):-
    length(X, 0),
    length(Y, 0).



