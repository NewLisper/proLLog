reverse(X,[],X).
reverse(X,[Y|Ys],Acc) :- reverse(X,Ys,[Y|Acc]).
reverse(X,Ls) :- reverse(X,Ls,[]).

?- reverse(X,[a,b,c,d]).
