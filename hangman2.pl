% The game takes advantage of SWI Prolog libraries.
% Using other implementations may not work.
% Run "play." as a query to play the game.

% ------------------------------------------------------------------
%                             TRUTHS
% ------------------------------------------------------------------

% string that the user is trying to guess
:- dynamic game_word/1.

% partial solution that only displays the known characters
:- dynamic solution/1.

% number of wrong guesses
:- dynamic fail_count/1.

% string of known characters
:- dynamic known_chars/1.

% ------------------------------------------------------------------
%                             PREDICATES
% ------------------------------------------------------------------

set_solution(X) :- asserta(solution(X)).

set_game_word(X) :- atom_string(X, S), asserta(game_word(S)).

set_fail_count(X) :- asserta(fail_count(X)).

set_known_chars(X) :- asserta(known_chars(X)).

% draws gallows on screen based on the value of fail count
gallows :-
   fail_count(X),
   ((X is 1, draw_gallows1);
   (X is 2, draw_gallows2);
   (X is 3, draw_gallows3);
   (X is 4, draw_gallows4);
   (X is 5, draw_gallows5);
   (X is 6, draw_gallows6);
   (X is 7, draw_gallows7);
   (X is 8, draw_gallows8);
   fail).

%--------------------------------------------------------------------
%          PREDICATES USED WHEN BUILDING THE PARTIAL SOLUTION
%--------------------------------------------------------------------

% adds one "-" character to solution, WORKS!
add_unknown_solution :-
   solution(S),
   (
       (S == [], set_solution([45]))
       ;
       (add_list_element(S, 45, S1), set_solution(S1))
   ).

% adds x to solution, WORKS!
add_to_solution(X) :-
   solution(S),
   ((S == [], set_solution([X]));
   (add_list_element(S, X, S1), set_solution(S1))).

% true, if x is a known character
char_is_known(X) :-
   known_chars(K), K \= "", string_codes(K, C), member(X, C).

% adds x as the last element of the list
add_list_element([], X, [X]).
add_list_element([H|T], X, [H|T2]) :- add_list_element(T, X, T2).

% if head is a known character, adds it to solution
% otherwise adds a "-" character to solution
process_char_list([]).
process_char_list([H|T]) :-
   (
    (char_is_known(H), add_to_solution(H))
    ;
    add_unknown_solution
   ), process_char_list(T).

% resets solution and processes each game word character
% to build a new one
build_solution :-
   set_solution([]), game_word(G), string_codes(G, L), process_char_list(L).


%--------------------------------------------------------------------
%            PREDICATES USED WHEN EVALUATING USER GUESSES
%--------------------------------------------------------------------

% if x is not in list of known characters, adds it to the list.
% otherwise does nothing
add_to_known_chars(X) :-
   known_chars(L),
   (
       sub_string(L, _, 1, _, X)
       ;
       string_concat(X, L, L1), set_known_chars(L1)
   ).

% true, if x is the same as game word.
right_word(X) :-
   game_word(Y),
   X == Y,
   right_word_text.

% increases fail count by 1, displays info and draws gallows.
wrong :-
   fail_count(Y), succ(Y, Z), set_fail_count(Z), wrong_guess_text, gallows.

% if x is part of game word, adds it to known characters
% and displays info.
% otherwise branches to wrong
char(X) :-
   atom_string(X, S), game_word(G),
   (
       (sub_string(G, _, 1, _, S), add_to_known_chars(X), right_char_text)
       ; wrong
   ).

% branhes to right_word, if x is the game word.
% otherwise branches to wrong.
word(X) :- (atom_string(X, S), right_word(S)) ; wrong.

% sets fail count to 0, resets known characters
% and displays intro texts
play :-
   set_fail_count(0), set_known_chars(""), play_text, help.


% ------------------------------------------------------------------
%                              TEXTS
% ------------------------------------------------------------------

% displays intoduction texts
play_text :-
   write_ln('**********************************'),
   write_ln('   You are now playing hangman!   '),
   write_ln('**********************************'),
   write_ln('First, write set_game_word(Word). to set the word for the game.'),
   write_ln('').

% displays instructions
help :-
    write_ln('*******************'),
    write_ln('   How to play:    '),
    write_ln('*******************'),
    write_ln('Enter char(Character). to guess a character. Use lower caps and guess one character at a time.'),
    write_ln('Enter word(Word). to guess a word. Use lower caps.'),
    write_ln('You can guess wrong seven times before losing.'),
    write_ln('*****************************************************'),
    write_ln('').

% displays info about wrong guess
wrong_guess_text :-
   write_ln('*****************************************************'),
   write_ln('You guessed wrong :('),
   write_ln('Try another word or character.'),
   write_ln('*****************************************************'),
   write_ln('').

% displays end texts when user wins
right_word_text :-
   game_word(X),
   write_ln('*****************************************************'),
   writef(X), write_ln(' is the correct answer, you have won the game! :D'),
   write_ln('Write (play.) to play again.'),
   write_ln('*****************************************************'),
   write_ln('').

% displays info, builds partial solution and shows it to user
right_char_text :-
   build_solution, solution(X), string_codes(S, X),
   write_ln('*****************************************************'),
   write_ln('You guessed right :)'),
   write('Here is what you know so far: '), writef(S), write_ln(''),
   write_ln('Try another word or character.'),
   write_ln('*****************************************************'),
   write_ln('').


% ------------------------------------------------------------------
%                              GRAPHICS
% ------------------------------------------------------------------

draw_gallows1 :-
   write_ln('        '),
   write_ln('        '),
   write_ln('        '),
   write_ln('        '),
   write_ln('        '),
   write_ln('        '),
   write_ln('        '),
   write_ln('   -----').
draw_gallows2 :-
   write_ln('        '),
   write_ln('     |  '),
   write_ln('     |  '),
   write_ln('     |  '),
   write_ln('     |  '),
   write_ln('     |  '),
   write_ln('     |  '),
   write_ln('   -----').
draw_gallows3 :-
   write_ln('        '),
   write_ln('  ---|  '),
   write_ln('     |  '),
   write_ln('     |  '),
   write_ln('     |  '),
   write_ln('     |  '),
   write_ln('     |  '),
   write_ln('   -----').
draw_gallows4 :-
   write_ln('        '),
   write_ln('  ---|  '),
   write_ln('  |  |  '),
   write_ln('     |  '),
   write_ln('     |  '),
   write_ln('     |  '),
   write_ln('     |  '),
   write_ln('   -----').
draw_gallows5 :-
   write_ln('        '),
   write_ln('  ---|  '),
   write_ln('  |  |  '),
   write_ln('  O  |  '),
   write_ln('     |  '),
   write_ln('     |  '),
   write_ln('     |  '),
   write_ln('   -----').
draw_gallows6 :-
   write_ln('        '),
   write_ln('  ---|  '),
   write_ln('  |  |  '),
   write_ln('  O  |  '),
   write_ln('  |  |  '),
   write_ln('     |  '),
   write_ln('     |  '),
   write_ln('   -----').
draw_gallows7 :-
   write_ln('        '),
   write_ln('  ---|  '),
   write_ln('  |  |  '),
   write_ln(' _O_ |  '),
   write_ln('  |  |  '),
   write_ln('     |  '),
   write_ln('     |  '),
   write_ln('   -----').
draw_gallows8 :-
   write_ln('        '),
   write_ln('  ---|  '),
   write_ln('  |  |  '),
   write_ln(' _O_ |  '),
   write_ln('  |  |  '),
   write_ln(' //  |  '),
   write_ln('     |  '),
   write_ln('   -----'),
   write_ln('*****************************************************'),
   write_ln('You have lost the game!'),
   write_ln('Write play. to play again.'),
   write_ln('*****************************************************'),
   write_ln('').







