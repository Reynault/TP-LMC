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
    functor(Func1, Name1, Arity1),
    functor(Func2, Name2, Arity2),
    %Func1 =.. [Nom1| Param1],
    %Func2 =.. [Nom2| Param2],
    verifNom(Name1, Name2),
    verifArite(Arity1, Arity2),
    !.

verifNom(Nom1, Nom2) :-
    Nom1 \== Nom2.

/*
    Vérification au niveau du nombre d'arité
*/
verifArite(Arity1, Arity2) :-
    Arity1 \== Arity2.
    %echo(Termes1),
    %length(Termes1, Nb1),
    %length(Termes2, Nb2),
    %Nb1 \== Nb2.

% Rename

/*
    On vérifie si les deux parties de l'équation sont deux variables
*/
regle(X ?= T, rename) :-
    var(X),
    var(T),
    !.

% Simplifie (Vrai si on peut appliquer la règle)

/*
    Peux être appliquée sur les deux paramètres
    si il peux etre appliqué alors on ne va pas plus loin, on va déjà
    appliquer cette règle
*/
regle(X ?= T, simplify) :-
    var(X), atomic(T),
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
    !.

% Orient (Vrai si on peut appliquer la règle)

/*
    Test si orient peux etre appliquée sur les deux paramètres
    si il peux etre appliqué alors on ne va pas plus loin, on va déjà
    appliquer cette règle
*/
regle(T ?= X, orient) :-
    nonvar(T), var(X),
    !.

% Decompose (Vrai si on peut appliquer la règle)

/*
    Règle de décomposition, cette règle peut s'appliquer dans le cas où les deux
    symboles de fonction sont les mêmes. (même nom et même nombre de paramètres)
*/
regle(Func1 ?= Func2, decompose) :-
    %Func1 =.. [F| Termes1],
    %Func2 =.. [G| Termes2],
    %F == G,
    functor(Func1, Name1, Arity1),
    functor(Func2, Name2, Arity2),
    Name1 == Name2,
    Arity1 == Arity2,
    %length(Termes1, Nb1),
    %length(Termes2, Nb2),
    %Nb1 == Nb2,
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
    %Fonc1 =.. [_| Param1],
    %Fonc2 =.. [_| Param2],
    arg(Argi1, Fonc1, Arg1),
    arg(Argi2, Fonc2, Arg2),
    % Ajout des nouvelles équations
    %decompose(Param1, Param2, Liste),
    % Ajout de la liste dans le programme P
    %append(Liste, P, Q),
    append([Arg1 ?= Arg2], P, Q),
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


% Unifie sans stratègie (Question 1)

unifie([]) :-
    echo("\n"),
    !.

unifie(Programme) :-
    Programme = [X| P],
    echo("system:   "), echo(Programme), echo("\n"),
    regle(X, R),
    echo(R), echo(":   "), echo(X), echo("\n"),
    reduit(R, X, P, Q),
    unifie(Q),
    !.

% Unifie avec choix_premier

/*
    Unification avec choix_premier, on prend la première
    équation du programme, on récupère la règle à appliquer,
    puis on réduit le programme.
*/

unifie([], choix_premier) :-
    echo("\n"),
    !.

unifie(P, choix_premier) :-
    echo("system:   "), echo(P), echo("\n"),
    choix_premier(P, Q, E, R),
    echo(R), echo(":   "), echo(E), echo("\n"),
    reduit(R, E, Q, Resultat),
    unifie(Resultat, choix_premier),
    !.

% Unifie avec choix_pondere

unifie(P, choix_pondere) :-
    echo("system:   "), echo(P), echo("\n"),
    choix_pondere(P, Q, E, R),
    echo(R), echo(":   "), echo(E), echo("\n"),
    reduit(R, E, Q, Resultat),
    unifie(Resultat, choix_pondere),
    !.

% Choix

% Choix_premier

/*
    Le prédicat choix_premier récupère la première équation
    du programme P, puis choisi la règle de celle si.

    R devient la règle choisie sur l'équation E
    P devient le système Q
*/
choix_premier([PremiereEquation| P], Q, E, R) :-
    % E devient la première équation
    E = PremiereEquation,
    % On retrouve la règle à effectuer
    regle(E, R),
    % Q devient le programme sans la première équation
    Q = P,
    !.

% Choix_pondere

choix_pondere(P, Q, E, R) :-
    recupRegle(P, [Equation| _]),
    Equation = [Poids, E],
    ponderationVersRegle(Poids, R),
    delete(P, E, Q),
    !.

/*
    Prédicat de récupération des règles

    Regles contient la liste des règles pour chaque équation
    du programme P
*/

recupRegle([], Regles) :-
    Regles = [].

recupRegle([E| P], Regles) :-
    recupRegle(P, New),
    regle(E, R),
    ponderer(R, Poids),
    append([[Poids, E]], New, Regles),
    !.

ponderer(clash, Poids) :-
    Poids = 1,
    !.

ponderer(check, Poids) :-
    Poids = 1,
    !.

ponderer(rename, Poids) :-
    Poids = 2,
    !.

ponderer(simplify, Poids) :-
    Poids = 2,
    !.

ponderer(orient, Poids) :-
    Poids = 3,
    !.

ponderer(decompose, Poids) :-
    Poids = 4,
    !.

ponderer(expand, Poids) :-
    Poids = 5,
    !.

ponderationVersRegle(Num, R) :-
    ponderer(R, Num),
    !.

% ---------------------- FIN QUESTION N°1 : Execution des de l'algorithme sur les deux exemples fournis dans le sujet

/*

Commande :

    ?- unifie([f(X,Y) ?= f(g(Z),h(a)), Z ?= f(Y)]).

Résultat :

    system:   [f(_4736,_4738)?=f(g(_4742),h(a)),_4742?=f(_4738)]
    decompose:   f(_4736,_4738)?=f(g(_4742),h(a))
    system:   [_4736?=g(_4742),_4738?=h(a),_4742?=f(_4738)]
    expand:   _4736?=g(_4742)
    system:   [_4738?=h(a),_4742?=f(_4738)]
    expand:   _4738?=h(a)
    system:   [_4742?=f(h(a))]
    expand:   _4742?=f(h(a))

    X = g(f(h(a))),
    Y = h(a),
    Z = f(h(a)).

Commande :

    ?- unifie([f(X,Y) ?= f(g(Z),h(a)), Z ?= f(X)]).

Résultat :

    system:   [f(_4736,_4738)?=f(g(_4742),h(a)),_4742?=f(_4736)]
    decompose:   f(_4736,_4738)?=f(g(_4742),h(a))
    system:   [_4736?=g(_4742),_4738?=h(a),_4742?=f(_4736)]
    expand:   _4736?=g(_4742)
    system:   [_4738?=h(a),_4742?=f(g(_4742))]
    expand:   _4738?=h(a)
    system:   [_4742?=f(g(_4742))]
    check:   _4742?=f(g(_4742))
    false.
*/