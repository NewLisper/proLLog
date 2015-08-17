last_but_one(X,[X,Y]).
last_but_one(X,[Z,Y|Ys]) :- last_but_one(X,[Y|Ys]).

?-last_but_one(X,[a,b,c]).
