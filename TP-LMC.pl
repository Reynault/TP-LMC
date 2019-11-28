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

% Configuration pre-execution

:- style_check(-discontiguous).
:- set_echo.

% Question n°1

% Règle --> Check, Clash, Rename, Simplify, Expand, Orient, Decompose

% Regle check associée au test d'occurence, qui est vrai s'il y X dans T
regle(X ?= T, check) :-
    \+occur_check(X, T),
    !.

% Test d'occurence (Vrai si V ne se trouve pas dans T)

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

% Clash (Vrai si on peut appliquer la règle)

/*
    Règle clash, on vérifie deux choses, le nom des deux fonctions est différent ou le nombre
    d'arité est différent. 
*/

/*
    Vérification au niveau du nom
*/
regle(Func1 ?= Func2, clash) :-
    compound(Func1),
    compound(Func2),
    Func1 =.. [Nom1| Param1],
    Func2 =.. [Nom2| Param2],
    verifNom(Nom1, Nom2),
    verifArite(Param1, Param2),
    echo("\n clash peux etre appliquee sur: \n\t"),
    echo(Func1), echo(" ?= "), echo(Func2),
    !.

verifNom(Nom1, Nom2) :-
    Nom1 \== Nom2.

/*
    Vérification au niveau du nombre d'arité
*/
verifArite(Termes1, Termes2) :-
    echo(Termes1),
    length(Termes1, Nb1),
    length(Termes2, Nb2),
    Nb1 \== Nb2.

% Rename

/*
    On vérifie si les deux parties de l'équation sont deux variables
*/
regle(X ?= T, rename) :-
    var(X),
    var(T),
    echo("\n rename peux etre appliquee sur: \n\t"),
    echo(X), echo(" ?= "), echo(T),
    !.

% Simplifie (Vrai si on peut appliquer la règle)

/*
    Peux être appliquée sur les deux paramètres
    si il peux etre appliqué alors on ne va pas plus loin, on va déjà
    appliquer cette règle
*/
regle(X ?= T, simplify) :-
    var(X), atomic(T),
    echo("\n simplify peux etre appliquee sur: \n\t"),
    echo(X), echo(" ?= "), echo(T),
    !.

% Expand (Vrai si on peut appliquer la règle)

/*
    Vérification si X est une variable, si T est composé, et si X n'est pas
    dans T, on utilise l'occur check précédemment défini.
*/
regle(X ?= T, expand) :-
    var(X),
    compound(T),
    occur_check(X, T),
    echo("\n expand peux etre appliquee sur: \n\t"),
    echo(X), echo(" ?= "), echo(T),
    !.

% Orient (Vrai si on peut appliquer la règle)

/* 
    Test si orient peux etre appliquée sur les deux paramètres
    si il peux etre appliqué alors on ne va pas plus loin, on va déjà
    appliquer cette règle
*/
regle(T ?= X, orient) :-
    nonvar(T), var(X),
    echo("\n Orient peux etre appliquee sur: \n\t"),
    echo(T), echo(" ?= "), echo(X),
    !.

% Decompose (Vrai si on peut appliquer la règle)

/*
    Règle de décomposition, cette règle peut s'appliquer dans le cas où les deux
    symboles de fonction sont les mêmes. (même nom et même nombre de paramètres)
*/
regle(Func1 ?= Func2, decompose) :-
    Func1 =.. [F| Termes1],
    Func2 =.. [G| Termes2],
    F == G,
    length(Termes1, Nb1),
    length(Termes2, Nb2),
    Nb1 == Nb2,
    echo("\n decompose peux etre appliquee sur: \n\t"),
    echo(Func1), echo(" ?= "), echo(Func2),
    !.


% Réduit : 

% Rename/ Expand/ Simplify

/*
    Prédicat réduit pour la règle rename, il applique le renommage sur
    le programme P en fonction de l'équation E, et rend le résultat
    dans Q
*/
reduit(rename, X ?= T, P, Q) :-
    elimination(X ?= T, P, Q),
    !.

/*
    Prédicat réduit pour la règle expand, il applique l'extension sur
    le programme P en fonction de l'équation E, et rend le résultat
    dans Q
*/
reduit(expand, X ?= T, P, Q) :-
    elimination(X ?= T, P, Q),
    !.

/*
    Prédicat réduit pour la règle simplify, il applique la simplification sur
    le programme P en fonction de l'équation E, et rend le résultat
    dans Q
*/
reduit(simplify, X ?= T, P, Q) :-
    elimination(X ?= T, P, Q),
    !.

/*
    Prédicat elimination qui permet d'appliquer l'unification permettant d'appliquer
    les règles rename, expand et simplify
*/
elimination(X ?= T, P, Q) :-
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
reduit(decompose, Fonc1 ?= Fonc2, P, Q) :-
    % Récupération des arguments
    Fonc1 =.. [_| Param1],
    Fonc2 =.. [_| Param2],

    % Ajout des nouvelles équations
    decompose(Param1, Param2, Liste),
    % Ajout de la liste dans le programme P
    append(Liste, P, Q),
    !.

/*
    Prédicat de decomposition, cas initial où les deux listes des
    arguments sont vides.
*/
decompose([], [], _) :-
    !.

/*
    Prédicat de decomposition, on prend deux listes correspondant aux paramètres des deux fonctions.
    On ajoute ensuite la nouvelle équations à une autre liste, de sorte à cumuler toutes les
    équations.
*/
decompose([Arg1| Args1], [Arg2| Args2], Liste) :-
    decompose(Args1, Args2, Temp),
    append([Arg1 ?= Arg2], Temp, Liste),
    !.

% Orient

/*
    Prédicat reduit pour la règle orient, le prédicat prend l'équation E et l'inverse
    puis l'ajoute au programme P, le résulat est alors stocké dans Q
*/
reduit(orient, X ?= T, P, Q) :-
    % Ajout dans P de l'équation inversée
    append([X ?= T], P, Q),
    !.


% Unifie

unifie([]) :-
    echo("Fin"),
    !.

unifie([X ?= T| P]) :-
    echo("Test de la regle"),
    regle(X ?= T, R),
    echo("\nApplication de la regle :"), echo(R), echo("\n"),
    reduit(R, X ?= T, P, Q),
    echo("\nContinuation de l'algo sur "), echo(Q), echo("\n"),
    unifie(Q),
    !.


% ---------------------- FIN QUESTION N°1 : Execution des de l'algorithme sur les deux exemples fournis dans le sujet

/*

Commande :

    ?- unifie([f(X,Y) ?= f(g(Z),h(a)), Z ?= f(Y)]).

Résultat : 

    Test de la regle
     decompose peux etre appliquee sur: 
            f(_14362,_14364) ?= f(g(_14368),h(a))
    Application de la regle :decompose

    Continuation de l'algo sur [_14362?=g(_14368),_14364?=h(a),_14368?=f(_14364)]
    Test de la regle
     expand peux etre appliquee sur: 
            _14362 ?= g(_14368)
    Application de la regle :expand

    Continuation de l'algo sur [_14364?=h(a),_14368?=f(_14364)]
    Test de la regle
     expand peux etre appliquee sur: 
            _14364 ?= h(a)
    Application de la regle :expand

    Continuation de l'algo sur [_14368?=f(h(a))]
    Test de la regle
     expand peux etre appliquee sur: 
            _14368 ?= f(h(a))
    Application de la regle :expand

    Continuation de l'algo sur []
    Fin
    X = g(f(h(a))),
    Y = h(a),
    Z = f(h(a)).

Commande :
    
    ?- unifie([f(X,Y) ?= f(g(Z),h(a)), Z ?= f(X)]).

Résultat :

    Test de la regle
     decompose peux etre appliquee sur: 
            f(_8796,_8798) ?= f(g(_8802),h(a))
    Application de la regle :decompose

    Continuation de l'algo sur [_8796?=g(_8802),_8798?=h(a),_8802?=f(_8796)]
    Test de la regle
     expand peux etre appliquee sur: 
            _8796 ?= g(_8802)
    Application de la regle :expand

    Continuation de l'algo sur [_8798?=h(a),_8802?=f(g(_8802))]
    Test de la regle
     expand peux etre appliquee sur: 
            _8798 ?= h(a)
    Application de la regle :expand

    Continuation de l'algo sur [_8802?=f(g(_8802))]
    Test de la regle
    Application de la regle :check
    false.
*/