drop([],N,C,[]).
drop([X|Xs],N,s(z),Ys) :- drop(Xs,N,N,Ys).
drop([X|Xs],N,s(C),[X|Ys]) :- drop(Xs,N,C,Ys).

drop(Xs,N,X) :- drop(Xs,N,N,X).

?- drop([a,b,c,d,e,f,g,h,i,k],s(s(s(z))),X).
