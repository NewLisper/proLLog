hbal_tree(z,nil) :- !.
hbal_tree(s(z),t(x,nil,nil)) :- !.
hbal_tree(s(s(D)),t(x,L,R)) :-
    distr(s(D),D,DL,DR),
    hbal_tree(DL,L), hbal_tree(DR,R).

distr(D1,D2,D1,D1).
distr(D1,D2,D1,D2).
distr(D1,D2,D2,D1).

?- hbal_tree(s(s(s(z))),T).
