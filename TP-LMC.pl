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
/*
p(x ?= x, decompose).
p(f(x, A) ?= f(y, B), decompose) :- p(x ?= y, decompose).
*/

/*
p(f([X|Y]), f(W|Z)) :- echo(X), echo(W).
*/
/*
afficherattribut(Func1, Func2) :-
    \+var(Func1),
    \+var(Func2),
    Func1 =.. [_ | Terms1],
    Func2 =.. [_ | Terms2],
    echo(bagof(Func1)),
    echo(bagof(Func2)).
*/

afficherattribut(Func) :-
    \+var(Func),
    Func =.. [_ | Terms],
    echo(Func).


afficherParam([X|L]) :- echo(X), afficherParam(L), afficherattribut(X).


unifie(Func1, Func2):-
    \+var(Func1),
    \+var(Func2),
    Func1 =.. [X | Terms1],
    Func2 =.. [Y | Terms2],
    echo(X), echo(Terms1),
    echo(Y), echo(Terms2).