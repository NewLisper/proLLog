internals(nil,[]).
internals(t(X,nil,nil),[]) :- !.
internals(t(X,L,R),[X|S]) :- 
    internals(L,SL), internals(R,SR), append(SL,SR,S).

append([],L,L).
append([X|Xs],L,[X|Zs]) :- append(Xs,L,Zs).
 
?- internals(t(m, t(n, t(a, nil, nil), t(c, nil, nil)), t(b, nil, t(d, nil, nil))),N).
