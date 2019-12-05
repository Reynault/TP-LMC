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

% Règle --> Remove, Check, Clash, Rename, Simplify, Expand, Orient, Decompose

% Règle remove qui permet d'enlever une équation composée des deux même variables, comme X ?= X par exemple
regle(X ?= T, remove) :-
    var(X),
    var(T),
    X == T,
    !.

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

regle(Func1 ?= Func2, clash) :-
    compound(Func1),
    compound(Func2),
    %Func1 =.. [Nom1| _],
    %Func2 =.. [Nom2| _],
    %Nom1 \== Nom2,
    functor(Func1, Name1, _),
    functor(Func2, Name2, _),
    Name1 \== Name2,
    !.

regle(Func1 ?= Func2, clash) :-
    compound(Func1),
    compound(Func2),
    %Func1 =.. [_| Param1],
    %Func2 =.. [_| Param2],

    %length(Param1, Nb1),
    %length(Param2, Nb2),
    %Nb1 \== Nb2,

    functor(Func1, _, Arity1),
    functor(Func2, _, Arity2),
    Arity1 \== Arity2,
    !.

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
    compound(Func1),
    compound(Func2),
    %Func1 =.. [F| Termes1],
    %Func2 =.. [G| Termes2],
    %F == G,
    %length(Termes1, Nb1),
    %length(Termes2, Nb2),
    %Nb1 == Nb2,

    functor(Func1, Name1, Arity1),
    functor(Func2, Name2, Arity2),
    Name1 == Name2,
    Arity1 == Arity2,
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

% Réduit :

% Reduit de remove (ne fait rien)

reduit(remove, _, P, Q) :-
    Q = P,
    !.

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

% Decompose without list

/*
    Prédicat reduit qui permet d'appliquer la règle decompose sur l'équation E.
    On ajout alors au programme P les nouvelles équations, le résultat est placé dans Q.
*/
reduit(decompose, Fonc1 ?= Fonc2, P, Q) :-
    % Récupération du nombre d'arguments
    functor(Fonc1, _, Arite),

    % Ajout des nouvelles équations
    decompose(Fonc1, Fonc2, Arite, Liste),
    % Ajout de la liste dans le programme P
    append(Liste, P, Q),
    !.

/*
    Prédicat de decomposition, cas initial où l'argument
    parcouru est 0
*/
decompose(_, _, 0, _) :-
    !.

/*
    Prédicat de decomposition, on prend deux fonctions et on récupère le ième argument
    afin d'ajouter l'équation Arg1 ?= Arg2 au programme.
*/
decompose(Fonc1, Fonc2, Arite, Liste) :-
    New is Arite - 1,
    decompose(Fonc1, Fonc2, New, Res),
    arg(Arite, Fonc1, Arg1),
    arg(Arite, Fonc2, Arg2),
    append(Res, [Arg1 ?= Arg2], Liste),
    !.

% Decompose with list

/*
    Prédicat reduit qui permet d'appliquer la règle decompose sur l'équation E.
    On ajout alors au programme P les nouvelles équations, le résultat est placé dans Q.
*/
/*reduit(decompose, Fonc1 ?= Fonc2, P, Q) :-
    % Récupération des arguments
    Fonc1 =.. [_| Param1],
    Fonc2 =.. [_| Param2],

    % Ajout des nouvelles équations
    decompose(Param1, Param2, Liste),
    % Ajout de la liste dans le programme P
    append(Liste, P, Q),
    !.
*/
/*
    Prédicat de decomposition, cas initial où les deux listes des
    arguments sont vides.
*/
/*decompose([], [], _) :-
    !.
*/
/*
    Prédicat de decomposition, on prend deux listes correspondant aux paramètres des deux fonctions.
    On ajoute ensuite la nouvelle équations à une autre liste, de sorte à cumuler toutes les
    équations.
*/
/*decompose([Arg1| Args1], [Arg2| Args2], Liste) :-
    decompose(Args1, Args2, Temp),
    append([Arg1 ?= Arg2], Temp, Liste),
    !.
*/

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

% Unifie avec choix_pondere

unifie([], choix_pondere) :-
    echo("\n"),
    !.

unifie(P, choix_pondere) :-
    echo("system:   "), echo(P), echo("\n"),
    choix_pondere(P, Q, E, R),
    echo(R), echo(":   "), echo(E), echo("\n"),
    reduit(R, E, Q, Resultat),
    unifie(Resultat, choix_pondere),
    !.

% Choix_pondere

choix_pondere(P, Q, E, R) :-
    recupRegle(P, Regles),
    sort(1, @=<, Regles, [Equation| _]),
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

ponderer(remove, Poids) :-
    Poids = 0,
    !.

ponderer(clash, Poids) :-
    Poids = 1,
    !.

ponderer(check, Poids) :-
    Poids = 2,
    !.

ponderer(rename, Poids) :-
    Poids = 3,
    !.

ponderer(simplify, Poids) :-
    Poids = 4,
    !.

ponderer(orient, Poids) :-
    Poids = 5,
    !.

ponderer(decompose, Poids) :-
    Poids = 6,
    !.

ponderer(expand, Poids) :-
    Poids = 7,
    !.

ponderationVersRegle(Num, R) :-
    ponderer(R, Num),
    !.

% Unifie avec choix aléatoire

unifie([], choix_aleatoire) :-
    echo("\n"),
    !.

unifie(P, choix_aleatoire) :-
    echo("system:   "), echo(P), echo("\n"),
    choix_aleatoire(P, Q, E, R),
    echo(R), echo(":   "), echo(E), echo("\n"),
    reduit(R, E, Q, Resultat),
    unifie(Resultat, choix_aleatoire),
    !.

% Choix aléatoire

/*
    Le prédicat choix aléatoire récupère une valeur aléatoire entre
    0 et la taille du programme.

    Il récupère ensuite l'équation E pointée par la valeur aléatoire
    et récupère la règle R qui peut s'appliquer.

    Puis donne à Q le programme P sans l'équation E.
*/
choix_aleatoire(P, Q, E, R) :-
    % Récupération de la taille de la liste
    length(P, Taille),
    % Pour récupérer un aléatoire qui indique une équation dans le programme
    random(0, Taille, Aleatoire),
    % On récupère ensuite cette équation
    recupElement(P, 0, Aleatoire, E),
    % Et on récupère la règle associée
    regle(E, R),
    % Q devient alors P moins E
    delete(P, E, Q),
    !.

/*
    Le prédicat recupElement permet de récupérer l'élément pointé par
    l'entier Aleatoire dans le programme P.
*/
recupElement([], _, _, _).

recupElement([E| P], K, Aleatoire, Element) :-
    % Si K est égal à Aleatoire, alors Element devient l'équation courante
    K == Aleatoire -> Element = E, !;
    % Sinon, incrémentation
    K1 is K + 1,
    recupElement(P, K1, Aleatoire, Element),
    !.



% Unifie avec choix inversé

unifie([], choix_inverse) :-
    echo("\n"),
    !.

unifie(P, choix_inverse) :-
    echo("system:   "), echo(P), echo("\n"),
    choix_inverse(P, Q, E, R),
    echo(R), echo(":   "), echo(E), echo("\n"),
    reduit(R, E, Q, Resultat),
    unifie(Resultat, choix_inverse),
    !.

% Choix inversé
choix_inverse(P, Q, E, R) :-
    recupRegle(P, Regles),
    sort(1, @>=, Regles, [Equation| _]),
    Equation = [Poids, E],
    ponderationVersRegle(Poids, R),
    delete(P, E, Q),
    !.

% Question n°3

% Prédicat unif(P, S)

unif(P, S) :-
    clr_echo,
    unifie(P, S).

trace_unif(P, S) :-
    set_echo,
    unifie(P, S).


% ---------------------- FIN QUESTION N°1 : Execution des de l'algorithme sur les deux exemples fournis dans le sujet

/*
Commande :

    ?- unifie([f(X,Y) ?= f(g(Z),h(a)), Z ?= f(Y)], choix_premier).

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

    ?- unifie([f(X,Y) ?= f(g(Z),h(a)), Z ?= f(X)], choix_premier).

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