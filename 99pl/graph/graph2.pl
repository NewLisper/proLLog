adj(X,[],[]).
adj(X,[n(X,Ls)|Rs],Ls) :- !.
adj(X,[n(Y,Ls)|Rs],Zs) :- adj(X,Rs,Zs).

path(G,A,A,[A]).
path(G,A,B,[A|Ps]) :- adj(A,G,Ls),select(Ls,S),path(G,S,B,Ps). 

select([X|Xs],X).
select([X|Xs],Z) :- select(Xs,Z).

?- path([n(r,[]),n(s,[r,u]),n(t,[]),n(u,[r]),n(v,[u])],s,r,Ps).
