ipl(t(X,[]),H,H) :- !.
ipl(t(X,Ts),H,N) :- ipls(Ts,s(H),N1),add(H,N1,N).

ipls([],H,z).
ipls([T|Ts],H,N) :- ipl(T,H,N1),ipls(Ts,H,N2),add(N1,N2,N).

ipl(T,N) :- ipl(T,z,N).

add(z,N,N).
add(s(N1),N2,s(N)) :- add(N1,N2,N).

?- ipl(t(a,[t(f,[t(g,[])]),t(c,[]),t(b,[t(d,[]),t(e,[])])]),N).
