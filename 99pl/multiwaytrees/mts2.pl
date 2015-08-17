nnodes(t(X,[]),s(z)).
nnodes(t(X,[T|Ts]),N) :- nnodes(T,N1),nnodes(t(X,Ts),N2),add(N1,N2,N).

add(z,N,N).
add(s(N1),N2,s(N)) :- add(N1,N2,N).

?- nnodes(t(a,[t(f,[])]),N).
