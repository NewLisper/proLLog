tree_ltl(t(X,[]),[X]) :- !.
tree_ltl(t(X,Ts),L2) :- tree_ltls(Ts,L),append([lp,X],L,L1),append(L1,[rp],L2).

tree_ltls([],[]).
tree_ltls([T|Ts],L3) :- tree_ltl(T,L1),tree_ltls(Ts,L2),append(L1,L2,L3).

append([],L,L).
append([X|Xs],L,[X|Zs]) :- append(Xs,L,Zs).

?-tree_ltl(t(a,[t(f,[t(g,[])]),t(c,[]),t(b,[t(d,[]),t(e,[])])]),L).
