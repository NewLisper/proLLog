dfs([],[]).
dfs([t(X,[])|Tss],[X,_|S1]) :- dfs(Tss,S1).
dfs([t(X,[T|Ts])|Tss],[X|S5]) :- dfs([T],S1),dfs(Ts,S2),dfs(Tss,S3),append(S1,S2,S4),append(S4,[_|S3],S5).

append([],L,L).
append([X|Xs],L,[X|Zs]) :- append(Xs,L,Zs).

?- dfs([t(a,[t(f,[t(g,[])]),t(c,[]),t(b,[t(d,[]),t(e,[])])])],S).
