atlevel(nil,N,[]).
atlevel(t(X,L,R),s(z),[X]) :- !.
atlevel(t(X,L,R),s(D),S) :-
   atlevel(L,D,SL), atlevel(R,D,SR), append(SL,SR,S).

append([],L,L).
append([X|Xs],L,[X|Zs]) :- append(Xs,L,Zs).

?- atlevel(t(m, t(n, t(a, nil, nil), t(c, nil, nil)), t(b, nil, t(d, nil, nil))),s(s(s(z))),S).
