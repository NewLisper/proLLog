split([],N,[],[]).
split(Xs,z,[],Xs).
split([X|Xs],s(N),[X|Ls],Rs) :- split(Xs,N,Ls,Rs).


append([],Ys,Ys).
append([X|Xs],Ys,[X|Zs]) :- append(Xs,Ys,Zs).

rotate(Xs,N,X) :- split(Xs,N,Ls,Rs),append(Rs,Ls,X).

?- rotate([a,b,c,d,e,f,g,h],s(s(s(z))),X).
