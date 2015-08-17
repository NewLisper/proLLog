split([],N,[],[]).
split(Xs,z,[],Xs).
split([X|Xs],s(N),[X|Ls],Rs) :- split(Xs,N,Ls,Rs).

?- split([a,b,c,d,e,f,g,h,i,k],s(s(s(z))),L1,L2).
