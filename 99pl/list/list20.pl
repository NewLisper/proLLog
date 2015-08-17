remove_at(X,[],N,[]).
remove_at(Y,[Y|Ys],s(z),Ys).
remove_at(X,[Y|Ys],s(N),[Y|Zs]) :- remove_at(X,Ys,N,Zs).

?- remove_at(X,[a,b,c,d],s(s(z)),R).
