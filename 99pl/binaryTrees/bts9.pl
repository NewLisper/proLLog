leaves(nil,[]).
leaves(t(X,nil,nil),[X]) :- !.
leaves(t(X,L,R),S) :- 
    leaves(L,SL), leaves(R,SR), append(SL,SR,S).

append([],L,L).
append([X|Xs],L,[X|Zs]) :- append(Xs,L,Zs).

?- leaves(t(m, t(n, t(a, nil, nil), t(c, nil, nil)), t(b, nil, t(d, nil, nil))),N).
