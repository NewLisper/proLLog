dupli([],[]).
dupli([X|Xs],[X,X|Ys]) :- dupli(Xs,Ys).

?- dupli([a,b,c,c,d],X).
