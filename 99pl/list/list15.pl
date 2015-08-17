dupli([],N,C,[]).
dupli([X|Xs],N,z,Ys) :- dupli(Xs,N,N,Ys).
dupli([X|Xs],N,s(C),[X|Ys]) :- dupli([X|Xs],N,C,Ys).

dupli(Xs,N,X) :- dupli(Xs,N,N,X).

?- dupli(Y,s(s(s(z))),X).
