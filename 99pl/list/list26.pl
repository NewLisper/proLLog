combination(z,Xs,[]).
combination(s(N),Xs,[X|Zs]) :- el(X,Xs,Rs),combination(N,Rs,Zs).

el(X,[X|L],L).
el(X,[Y|L],R) :- el(X,L,R).
 
?- combination(s(s(s(z))),[a,b,c,d,e,f],L).
