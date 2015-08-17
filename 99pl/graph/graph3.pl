adj(X,[],[]).
adj(X,[n(X,Ls)|Rs],Ls) :- !.
adj(X,[n(Y,Ls)|Rs],Zs) :- adj(X,Rs,Zs).

path(G,A,A,[A]).
path(G,A,B,[A|Ps]) :- adj(A,G,Ls),select(Ls,S),path(G,S,B,Ps).

select([X|Xs],X).
select([X|Xs],Z) :- select(Xs,Z).

in(X,[X|Xs]) :- !.
in(X,[Y|Xs]) :- in(X,Xs).

append([],L,L).
append([X|Xs],L,[X|Ys]) :- append(Xs,L,Ys).

cycle(G,A,C) :- adj(X,G,As),in(A,As),path(G,A,X,P),append(P,[A],C).

?- cycle([n(r,[s]),n(s,[r,u]),n(t,[]),n(u,[r]),n(v,[u])],s,Ps).
