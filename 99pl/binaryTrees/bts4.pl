add(X,nil,t(X,nil,nil)).
add(X,t(Root,L,R),t(Root,L1,R)) :- less(X,Root),!,add(X,L,L1).
add(X,t(Root,L,R),t(Root,L,R1)) :- add(X,R,R1).

less(z,X).
less(s(N1),s(N2)) :- less(N1,N2).

construct(L,T) :- construct(L,T,nil).

construct([],T,T).
construct([N|Ns],T,T0) :- add(N,T0,T1), construct(Ns,T,T1).
    

?- construct([s(s(s(z))),s(s(z)),s(s(s(s(s(z))))),s(s(s(s(s(s(s(z))))))),s(z)],T).
