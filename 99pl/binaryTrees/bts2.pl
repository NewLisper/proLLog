cbal_tree(z,nil) :- !.
cbal_tree(s(N),t(x,L,R)) :- 
    divideby2(N,N1),
    subtract(N,N1,N2), 
    distrib(N1,N2,NL,NR),
    cbal_tree(NL,L), cbal_tree(NR,R).

divideby2(z,z).
divideby2(s(z),z).
divideby2(s(s(N)),s(N1)) :- divideby2(N,N1). 

subtract(N,z,N).
subtract(s(N),s(N1),N2) :- subtract(N,N1,N2).

distrib(N,N,N,N) :- !.
distrib(N1,N2,N1,N2).
distrib(N1,N2,N2,N1).


?- cbal_tree(s(s(s(s(z)))),T).
