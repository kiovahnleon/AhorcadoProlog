% Ejecuta "play." como query para jugar.

% ------------------------------------------------------------------
%                             TRUTHS
% ------------------------------------------------------------------

% string que el usuario va a adivinar
:- dynamic game_word/1.

% solucion parcial que muestra los caracteres conocidos
:- dynamic solution/1.

% numero de intentos incorrectos
:- dynamic fail_count/1.

% string de caracteres conocidos
:- dynamic known_chars/1.

% ------------------------------------------------------------------
%                             PREDICATES
% ------------------------------------------------------------------

set_solution(X) :- asserta(solution(X)).

palabra_a_adivinar(X) :- atom_string(X, S), asserta(game_word(S)).

set_fail_count(X) :- asserta(fail_count(X)).

set_known_chars(X) :- asserta(known_chars(X)).

% dibuja el ahorcado basado en el valor de intentos fallidos.
dibujos :-
   fail_count(X),
   ((X is 1, dibuja_monito1);
   (X is 2, dibuja_monito2);
   (X is 3, dibuja_monito3);
   (X is 4, dibuja_monito4);
   (X is 5, dibuja_monito5);
   (X is 6, dibuja_monito6);
   (X is 7, dibuja_monito7);
   fail).

%--------------------------------------------------------------------
%          PREDICATES USED WHEN BUILDING THE PARTIAL SOLUTION
%--------------------------------------------------------------------

% agrega un caracter "-" a la solucion
add_unknown_solution :-
   solution(S),
   (
       (S == [], set_solution([45]))
       ;
       (add_list_element(S, 45, S1), set_solution(S1))
   ).

% agrega x a la solucion
add_to_solution(X) :-
   solution(S),
   ((S == [], set_solution([X]));
   (add_list_element(S, X, S1), set_solution(S1))).

% true, si x es un caracter conocido
char_is_known(X) :-
   known_chars(K), K \= "", string_codes(K, C), member(X, C).

% agrega x como el ultimo elemento de la lista
add_list_element([], X, [X]).
add_list_element([H|T], X, [H|T2]) :- add_list_element(T, X, T2).

% si head es un caracter conocido, lo agrega a la solucion
% si no, agrega caracter "-" a la solucion
process_char_list([]).
process_char_list([H|T]) :-
   (
    (char_is_known(H), add_to_solution(H))
    ;
    add_unknown_solution
   ), process_char_list(T).

% reestablece solucion y procesa cada caracter de game word
% para construir uno nuevo
build_solution :-
   set_solution([]), game_word(G), string_codes(G, L), process_char_list(L).


%--------------------------------------------------------------------
%            PREDICATES USED WHEN EVALUATING USER GUESSES
%--------------------------------------------------------------------

% si x no esta en la lista de caracteres conocidos, lo agrega a la lista
% si no, no hace nada
add_to_known_chars(X) :-
   known_chars(L),
   (
       sub_string(L, _, 1, _, X)
       ;
       string_concat(X, L, L1), set_known_chars(L1)
   ).

% true, si x es igual a game word
right_word(X) :-
   game_word(Y),
   X == Y,
   right_word_text.

% incrementa intentos fallidos en 1, muestra info y dibuja ahorcado
wrong :-
   fail_count(Y), succ(Y, Z), set_fail_count(Z), wrong_guess_text, dibujos.

% si x es parte de game word, lo agrega a caracteres conocidos
% y muestra info.
% otherwise branches to wrong
char(X) :-
   atom_string(X, S), game_word(G),
   (
       (sub_string(G, _, 1, _, S), add_to_known_chars(X), right_char_text)
       ; wrong
   ).

% branches to right_word, if x is the game word.
% otherwise branches to wrong.
word(X) :- (atom_string(X, S), right_word(S)) ; wrong.

% set contador de intentos fallidos a 0, reestablece caracteres conocidos
% y muestra textos de introduccion
play :-
   set_fail_count(0), set_known_chars(""), play_text, help.


% ------------------------------------------------------------------
%                              TEXTS
% ------------------------------------------------------------------

% muestra textos de introducción
play_text :-
   write_ln('**********************************'),
   write_ln('   Juego del ahorcado!   '),
   write_ln('**********************************'),
   write_ln('Primero, escribe palabra_a_adivinar(palabra). para que el jugador2 adivine.'),
   write_ln('').

% muestra instrucciones
help :-
    write_ln('*******************'),
    write_ln('   Como jugar:    '),
    write_ln('*******************'),
    write_ln('Introduce char(letra). para adivinar una letra. usa una letra minuscula, una a la vez.'),
    write_ln('Introduce word(palabra). para adivinar la palabra. Usa minusculas.'),
    write_ln('Tienes 6 intentos fallidos antes de perder la partida.'),
    write_ln('*****************************************************'),
    write_ln('').

% muestra información sobre intento incorrecto
wrong_guess_text :-
   write_ln('*****************************************************'),
   write_ln('Incorrecto:('),
   write_ln('Intenta otra letra o palabra.'),
   write_ln('*****************************************************'),
   write_ln('').

% muestra los textos finales cuando el usuario gana
right_word_text :-
   game_word(X),
   write_ln('*****************************************************'),
   writef(X), write_ln(' es la respuesta correcta, has ganado el juego ^-^'),
   write_ln('Escribe play. para jugar de nuevo
   .'),
   write_ln('*****************************************************'),
   write_ln('').

% muestra información, crea una solución parcial y se la muestra al usuario
right_char_text :-
   build_solution, solution(X), string_codes(S, X),
   write_ln('*****************************************************'),
   write_ln('Has acertado :)'),
   write('Esto es lo que has adivinado hasta ahora: '), writef(S), write_ln(''),
   write_ln('Prueba con otra letra o palabra.'),
   write_ln('*****************************************************'),
   write_ln('').


% ------------------------------------------------------------------
%                              GRAPHICS
% ------------------------------------------------------------------

dibuja_monito1 :-
   write_ln('        '),
   write_ln('  ---|  '),
   write_ln('  |  |  '),
   write_ln('     |  '),
   write_ln('     |  '),
   write_ln('     |  '),
   write_ln('     |  '),
   write_ln('   -----').
dibuja_monito2 :-
   write_ln('        '),
   write_ln('  ---|  '),
   write_ln('  |  |  '),
   write_ln('  O  |  '),
   write_ln('     |  '),
   write_ln('     |  '),
   write_ln('     |  '),
   write_ln('   -----').
dibuja_monito3 :-
   write_ln('        '),
   write_ln('  ---|  '),
   write_ln('  |  |  '),
   write_ln('  O  |  '),
   write_ln('  |  |  '),
   write_ln('     |  '),
   write_ln('     |  '),
   write_ln('   -----').
dibuja_monito4 :-
   write_ln('        '),
   write_ln('  ---|  '),
   write_ln('  |  |  '),
   write_ln(' _O  |  '),
   write_ln('  |  |  '),
   write_ln('     |  '),
   write_ln('     |  '),
   write_ln('   -----').
dibuja_monito5 :-
   write_ln('        '),
   write_ln('  ---|  '),
   write_ln('  |  |  '),
   write_ln(' _O_ |  '),
   write_ln('  |  |  '),
   write_ln('     |  '),
   write_ln('     |  '),
   write_ln('   -----').
dibuja_monito6 :-
   write_ln('        '),
   write_ln('  ---|  '),
   write_ln('  |  |  '),
   write_ln(' _O_ |  '),
   write_ln('  |  |  '),
   write_ln(' /   |  '),
   write_ln('     |  '),
   write_ln('   -----').
dibuja_monito7 :-
   write_ln('        '),
   write_ln('  ---|  '),
   write_ln('  |  |  '),
   write_ln(' _O_ |  '),
   write_ln('  |  |  '),
   write_ln(' //  |  '),
   write_ln('     |  '),
   write_ln('   -----'),
   write_ln('*****************************************************'),
   write_ln('Has perdido!'),
   write_ln('Escribe play. para jugar de nuevo.'),
   write_ln('*****************************************************'),
   write_ln('').