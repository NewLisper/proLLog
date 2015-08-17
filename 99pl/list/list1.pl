my_last(X,[X|[]]).
my_last(X,[Y|Ys]) :- my_last(X,Ys).

?-my_last(X,[a,b,c,d]).
