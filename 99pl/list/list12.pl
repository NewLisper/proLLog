decode(Xs,X) :- decode_helper(Xs,Ys),flat(Ys,X).

decode_helper([],[]).
decode_helper([X|Xs],[Y|Ys]) :- trans(X,Y),decode_helper(Xs,Ys).

trans([s(z),X],[X]).
trans([s(N),X],[X|Zs]) :- trans([N,X],Zs).

flat([],[]).
flat([[X]|Xs],[X|Zs]) :- flat(Xs,Zs).
flat([[Y|Ys]|Xs],[Y|Zs]) :- flat([Ys|Xs],Zs).

?- decode([[s(s(s(s(z)))),a],[s(z),b],[s(s(z)),c],[s(s(z)),a],[s(z),d],[s(s(s(s(z)))),e]],X).
