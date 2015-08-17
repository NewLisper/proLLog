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

mirror(nil,nil).
mirror(t(X,L1,R1),t(Y,L2,R2)) :- mirror(L1,R2),mirror(R1,L2).

symmetric(nil).
symmetric(t(X,L,R)) :- mirror(L,R).

sym_cbal_trees(N,T) :- cbal_tree(N,T),symmetric(T).

?- sym_cbal_trees(s(s(s(s(s(z))))),T).
