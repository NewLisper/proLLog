range(N,N,[N]) :- !.
range(S,E,[S|Zs]) :- range(s(S),E,Zs).

?- range(s(s(s(s(z)))),s(s(s(s(s(s(s(s(s(z))))))))),L).
