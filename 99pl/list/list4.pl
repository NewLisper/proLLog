length(X,[],X).
length(X,[Y|Ys],N) :- length(X,Ys,s(N)).

?- length(X,[a,b,[c,d],e],z).
