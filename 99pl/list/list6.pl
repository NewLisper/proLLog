reverse(X,[],X).
reverse(X,[Y|Ys],Acc) :- reverse(X,Ys,[Y|Acc]).
reverse(X,Ls) :- reverse(X,Ls,[]).

palindrome(Ls) :- reverse(Ls,Ls).

?- palindrome([a,b,c,b,a]).
