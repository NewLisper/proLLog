istree(t(X,[])).
istree(t(X,[T|Ts])) :- istree(T),istree(t(X,Ts)).

?- istree(t(a,[t(f,[t(g,[])]),t(c,[]),t(b,[t(d,[]),t(e,[])])])).
